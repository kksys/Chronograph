//
//  ContentViewModel.swift
//  ExampleChronometer
//
//  Created by KK Systems on 2022/09/19.
//

import Chronometer
import Combine
import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#endif

class BaseContentViewModel: ObservableObject {
	@Published var date: Date
	@Published var batteryInfo: BatteryInfo
	
	init() {
		self.date = .now
		self.batteryInfo = BatteryInfo(level: 0, state: .unknown)
	}
	
	func startTimer() {
		Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970) }
			.assign(to: &$date)
	}

	func subscribeBattery() {}
	func unsubscribeBattery() {}
}

#if os(iOS) || os(watchOS) || os(tvOS)
final class ContentViewModel: BaseContentViewModel {
	private var cancellable: Set<AnyCancellable> = Set()
	
	override func subscribeBattery() {
		UIDevice.current.isBatteryMonitoringEnabled = true
		
		batteryInfo.level = Double(UIDevice.current.batteryLevel)
		batteryInfo.state = UIDevice.current.batteryState
		
		NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
			.map { _ in Double(UIDevice.current.batteryLevel) }
			.sink { [self] in batteryInfo.level = $0 }
			.store(in: &cancellable)
		
		NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
			.map { _ in UIDevice.current.batteryState }
			.sink { [self] in batteryInfo.state = $0 }
			.store(in: &cancellable)
	}
	
	override func unsubscribeBattery() {}
}
#elseif os(macOS)
func batteryChanged(context: UnsafeMutableRawPointer?) {
	guard let context = context
	else { return }
	
	let _self = Unmanaged<ContentViewModel>.fromOpaque(context)
	_self.takeRetainedValue().updateBatteryInfo()
}

final class ContentViewModel: BaseContentViewModel {
	private var notificationSource: CFRunLoopSource?
	
	override func subscribeBattery() {
		batteryInfo.level = DeviceInfo.batteryLevel
		batteryInfo.state = DeviceInfo.batteryState
		
		if notificationSource != nil {
			unsubscribeBattery()
		}
		let opaque = Unmanaged.passRetained(self).toOpaque()
		let context = UnsafeMutableRawPointer(opaque)
		notificationSource = IOPSNotificationCreateRunLoopSource(batteryChanged, context).takeRetainedValue() as CFRunLoopSource
		CFRunLoopAddSource(CFRunLoopGetCurrent(), notificationSource, .defaultMode)
	}
	
	override func unsubscribeBattery() {
		guard let loop = notificationSource else { return }
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), loop, .defaultMode)
	}
	
	func updateBatteryInfo() {
		batteryInfo.level = DeviceInfo.batteryLevel
		batteryInfo.state = DeviceInfo.batteryState
		print(batteryInfo.level, batteryInfo.state)
	}
}
#endif

class ContentViewModelForScreenshot: BaseContentViewModel {
	override func startTimer() {
		self.date = .init(timeIntervalSince1970: 4230)
		self.batteryInfo = .init(level: 1.0, state: .full)
	}
}
