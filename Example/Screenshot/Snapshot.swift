//
//  Snapshot.swift
//  Example
//
//  Created by KK Systems on 2022/09/22.
//

import SwiftUI
import Combine
import CoreGraphics

extension UserDefaults {
	func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
		guard let data = self.value(forKey: key) as? Data else { return nil }
		return try? decoder.decode(type.self, from: data)
	}

	func set<T: Codable>(object: T, with key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
		let data = try? encoder.encode(object)
		self.set(data, forKey: key)
	}
}

enum ScreenshotError: Error {
	case targetNotFound
	case failedToCreateImageRep
	case failedToCreateCGContext
	case failedToMakeImage
	case deniedToAccessFile
	case deniedToRetrieveBookmark
}

struct SecurityScopedBookmarkItem: Codable {
	var bookmark: Data
	var absolutePath: String
	
	enum CodingKeys: String, CodingKey {
		case bookmark = "bookmark"
		case absolutePath = "absolutePath"
	}
}

class ScreenshotService: ObservableObject {
	let securityScopedBookmarkKey = "security-scoped-bookmark"
	
	func attachWindow() -> AnyPublisher<NSWindow, Never> {
		Timer.publish(every: 1, on: .main, in: .default)
			.autoconnect()
			.flatMap { _ -> AnyPublisher<NSWindow, Never> in
				guard let window = NSApplication.shared.mainWindow
				else { return Empty<NSWindow, Never>().eraseToAnyPublisher() }
				
				return Just<NSWindow>(window).eraseToAnyPublisher()
			}
			.first()
			.share()
			.eraseToAnyPublisher()
	}
	
	func takeScreenshot(window: NSWindow) throws -> NSBitmapImageRep {
		guard let controller = window.contentViewController
		else { throw ScreenshotError.targetNotFound }

		let view = controller.view
		let titlebarHeight = view.safeAreaInsets.top

		let rect = NSMakeRect(0, titlebarHeight / 2, window.frame.width, window.frame.height - titlebarHeight)
		guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: rect)
		else { throw ScreenshotError.failedToCreateImageRep }
		view.cacheDisplay(in: rect, to: bitmapRep)
		
		return bitmapRep
	}
	
	func modifySize(bitmapRep: NSBitmapImageRep, size: Int) throws -> NSBitmapImageRep {
		guard let cs = CGColorSpace(name: CGColorSpace.sRGB),
			  let c = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
		else { throw ScreenshotError.failedToCreateCGContext }
		
		NSGraphicsContext.current = NSGraphicsContext(cgContext: c, flipped: false)
		NSGraphicsContext.current?.imageInterpolation = .high
		NSGraphicsContext.current?.shouldAntialias = true
		
		bitmapRep.draw(in: NSMakeRect(0, 0, CGFloat(size), CGFloat(size)))
		guard let cgImage = c.makeImage()
		else { throw ScreenshotError.failedToMakeImage }

		return NSBitmapImageRep(cgImage: cgImage)
	}
	
	func saveImage(bitmapRep: NSBitmapImageRep, path: String) throws {
		var url = FileManager.default.homeDirectoryForCurrentUser
		url.appendPathComponent(path, isDirectory: false)

		if !isContainedAccessibleList(url: url),
		   let permittedURL = try? askPermissionToWrite(url: url) {
			url = permittedURL
		}
		
		guard let bookmarkedURL = try? generateBookmarkedURL(url: url) else {
			throw ScreenshotError.deniedToRetrieveBookmark
		}
		print(bookmarkedURL)

		if !bookmarkedURL.startAccessingSecurityScopedResource() {
			throw ScreenshotError.deniedToAccessFile
		}

		do {
			try bitmapRep.representation(using: .png, properties: [:])?.write(to: bookmarkedURL)
			print("\(path) was saved")
			bookmarkedURL.stopAccessingSecurityScopedResource()
		} catch {
			print("\(path) was not saved")
			print(error)
			bookmarkedURL.stopAccessingSecurityScopedResource()
		}
	}
	
	private func askPermissionToWrite(url: URL) throws -> URL {
		let panel = NSSavePanel()
		panel.directoryURL = url.baseURL
		panel.nameFieldStringValue = url.lastPathComponent
		panel.showsHiddenFiles = true
		let result = panel.runModal()

		if result == .OK, let selectedURL = panel.url {
			if !FileManager.default.fileExists(atPath: selectedURL.path) {
				FileManager.default.createFile(atPath: selectedURL.path, contents: nil)
			}
			
			return selectedURL
		}
		
		throw ScreenshotError.deniedToAccessFile
	}
	
	private func isEqual(url1: URL?, url2: URL?) throws -> Bool {
		let id1 = try url1?.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
		let id2 = try url2?.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
		
		return id1?.isEqual(id2) ?? false
	}
	
	private func isContainedAccessibleList(url: URL) -> Bool {
		var bookmarkList: [SecurityScopedBookmarkItem] = []
		
		if let items = UserDefaults.standard.object(
			[SecurityScopedBookmarkItem].self,
			with: securityScopedBookmarkKey
		) {
			bookmarkList = items
		}

		guard let result = try? bookmarkList.contains(where: { item in
			try self.isEqual(url1: url, url2: URL(string: item.absolutePath))
		})
		else { return false }
		
		return result
	}
	
	private func generateBookmarkedURL(url: URL) throws -> URL {
		var bookmarkList: [SecurityScopedBookmarkItem] = []
		var bookmark: Data?
		var isStaled: ObjCBool = ObjCBool(false)
		
		if let items = UserDefaults.standard.object(
			[SecurityScopedBookmarkItem].self,
			with: securityScopedBookmarkKey
		) {
			bookmarkList = items
		}

		if let item = try? bookmarkList.first(where: { try self.isEqual(url1: url, url2: URL(string: $0.absolutePath)) }) {
			bookmark = item.bookmark
		} else if let newBookmark = try? url.bookmarkData(
			options: .withSecurityScope,
			includingResourceValuesForKeys: nil,
			relativeTo: nil
		) {
			let item = SecurityScopedBookmarkItem(
				bookmark: newBookmark,
				absolutePath: url.absoluteString
			)
			bookmark = newBookmark
			bookmarkList.append(item)
			UserDefaults.standard.set(object: bookmarkList, with: securityScopedBookmarkKey)
			UserDefaults.standard.synchronize()
		}
		
		guard let bookmark = bookmark else {
			throw ScreenshotError.deniedToRetrieveBookmark
		}
		
		return try NSURL(
			resolvingBookmarkData: bookmark,
			options: .withSecurityScope,
			relativeTo: nil,
			bookmarkDataIsStale: &isStaled
		) as URL
	}
}

struct Snapshot<Content>: View where Content : View {
	@ViewBuilder var content: () -> Content
	@StateObject var screenshotService = ScreenshotService()
	@State var cancellable: Set<AnyCancellable> = Set()
	
    var body: some View {
		content()
			.onAppear {
				runPipeline()
			}
			.onDisappear {
				cancellable.forEach { $0.cancel() }
			}
    }
	
	private func runPipeline() {
		var sizeList: [Int] {
			let defaultIconSize = [16, 32, 64, 128, 256, 512, 1024]
			let extendIconSize = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180]
			
			return (defaultIconSize + extendIconSize).sorted()
		}

		let window$ = screenshotService.attachWindow()
		
		window$
			.handleEvents(receiveOutput: {_ in
				print("I'm starting to take the screenshot with dark mode...")

				NSApplication.shared.appearance = NSAppearance.init(named: .darkAqua)
			})
			.delay(for: 6, scheduler: DispatchQueue.main)
			.tryMap { window -> NSWindow in
				let bitmapRep = try screenshotService.takeScreenshot(window: window)

				for size in sizeList {
					let bitmap = try screenshotService.modifySize(bitmapRep: bitmapRep, size: size)
					try screenshotService.saveImage(
						bitmapRep: bitmap,
						path: "Desktop/workspace/Chronometer/Example/Screenshot/.screenshot/appicon_dark@\(size).png"
					)
				}

				return window
			}
			.eraseToAnyPublisher()
			.handleEvents(receiveOutput: {_ in
				print("I'm starting to take the screenshot with light mode...")

				NSApplication.shared.appearance = NSAppearance.init(named: .aqua)
			})
			.delay(for: 6, scheduler: DispatchQueue.main)
			.tryMap { window -> NSWindow in
				let bitmapRep = try screenshotService.takeScreenshot(window: window)

				for size in sizeList {
					let bitmap = try screenshotService.modifySize(bitmapRep: bitmapRep, size: size)
					try screenshotService.saveImage(
						bitmapRep: bitmap,
						path: "Desktop/workspace/Chronometer/Example/Screenshot/.screenshot/appicon_light@\(size).png"
					)
				}

				return window
			}
			.sink(
				receiveCompletion: { state in
					switch state {
					case .finished:
						Thread.sleep(forTimeInterval: 5)
						exit(0)
					default:
						break
					}
				},
				receiveValue: {_ in}
			)
			.store(in: &cancellable)
	}
}
