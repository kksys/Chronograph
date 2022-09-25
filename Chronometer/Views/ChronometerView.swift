//
//  ChronometerView.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/17.
//

import SwiftUI
import Combine

extension Date {
	func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
		return calendar.dateComponents(Set(components), from: self)
	}

	func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
		return calendar.component(component, from: self)
	}
}

#if os(iOS) || os(watchOS) || os(tvOS)
public typealias BatteryState = UIDevice.BatteryState
#elseif os(macOS)
public enum BatteryState: Int, @unchecked Sendable {
	case unknown = 0
	case unplugged = 1
	case charging = 2
	case full = 3
}
#endif

public struct BatteryInfo: Equatable {
	public static func == (lhs: BatteryInfo, rhs: BatteryInfo) -> Bool {
		lhs.level == rhs.level && lhs.state == rhs.state
	}
	
	public var level: Double
	public var state: BatteryState
	
	public init(level: Double, state: BatteryState) {
		self.level = level
		self.state = state
	}
}

struct ClockHands: View {
	var dateOfMonth: Double = 0
	var day: Double = 0
	var hour: Double = 0
	var minute: Double = 0
	var second: Double = 0

	func calculateSecondHandRect(geometry: GeometryProxy) -> CGRect {
		return CGRect(
			x: geometry.size.width / 2,
			y: geometry.size.height / 2,
			width: 4,
			height: geometry.size.width / 2 - 10
		)
	}
	
	var body: some View {
		GeometryReader { geometry in
			let secondHandRect = calculateSecondHandRect(geometry: geometry)
			
			ZStack {
				Group {
					ClockHand(width: 8, height: 120)
						.foregroundColor(.gray.opacity(0.7))
						.blur(radius: 2)
						.offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
						.rotationEffect(.degrees(360 / 12 * hour))
						.offset(x: 0, y: 3)
					
					ClockHand(width: 8, height: 120)
						.foregroundColor(.gray)
						.offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
						.rotationEffect(.degrees(360 / 12 * hour))
				}
				
				Group {
					ClockHand(width: 4, height: 230)
						.foregroundColor(.gray.opacity(0.7))
						.blur(radius: 2)
						.offset(x: geometry.size.width / 2, y: geometry.size.height / 2 + 2)
						.rotationEffect(.degrees(360 / 60 * minute))
						.offset(x: 0, y: 3)
					
					ClockHand(width: 4, height: 230)
						.foregroundColor(.gray)
						.offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
						.rotationEffect(.degrees(360 / 60 * minute))
				}
				
				Group {
					SecondClockHand(
						width: secondHandRect.width,
						height: secondHandRect.height,
						projectionHeight: secondHandRect.height / 4
					)
						.foregroundColor(.gray.opacity(0.7))
						.blur(radius: 1)
						.offset(
							x: secondHandRect.origin.x,
							y: secondHandRect.origin.y + 2
						)
						.rotationEffect(.degrees(360 / 60 * second))
						.offset(x: 0, y: 3)
					
					SecondClockHand(
						width: secondHandRect.width,
						height: secondHandRect.height,
						projectionHeight: secondHandRect.height / 4
					)
						.foregroundColor(.red)
						.offset(
							x: secondHandRect.origin.x,
							y: secondHandRect.origin.y
						)
						.rotationEffect(.degrees(360 / 60 * second))
				}
			}
		}
	}
}

public struct ChronometerView: View {
	@Binding var date: Date
	@Binding var batteryInfo: BatteryInfo
	
	let offsetDayWheel: CGFloat = 215
	let offsetDateWheel: CGFloat = 140
	let centerShaftRadius: CGFloat = 12

	@State var dateOfMonth: Double = 0
	@State var day: Double = 0
	@State var hour: Double = 0
	@State var minute: Double = 0
	@State var second: Double = 0
	@State var batteryLevel: Double = 0
	@State var batteryState: BatteryState = .unknown

	public init(date: Binding<Date>, batteryInfo: Binding<BatteryInfo>) {
		self._date = date
		self._batteryInfo = batteryInfo
	}
	
	public var body: some View {
		GeometryReader { geometry in
			ZStack {
				DateWheel()
					.background(.chronometer.background)
					.date(.chronometer.foreground)
					.frame(width: geometry.size.width - offsetDateWheel, height: geometry.size.height - offsetDateWheel)
					.rotationEffect(.degrees(-DateWheel.degreeOfDay * dateOfMonth))
				DayWheel()
					.background(.chronometer.background)
					.day(.chronometer.foreground)
					.frame(width: geometry.size.width - offsetDayWheel, height: geometry.size.height - offsetDayWheel)
					.rotationEffect(.degrees(-DayWheel.degreeOfDay * day))

				ChronometerBackground()
					.background(.chronometer.background)
					.foreground(.chronometer.foreground)

				BatteryLevel(
					level: batteryLevel,
					state: batteryState
				)
					.frame(
						width: geometry.size.width / 4,
						height: geometry.size.height / 4
					)
					.offset(
						x: geometry.size.width / 3.8,
						y: -geometry.size.height / 12
					)

				Group {
					SubmeterBackground()
						.background(.chronometer.background)
						.foreground(.chronometer.foreground)
						.frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
						.offset(x: -geometry.size.width / 4)
					SubmeterBackground()
						.background(.chronometer.background)
						.foreground(.chronometer.foreground)
						.frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
						.offset(y: -geometry.size.height / 4)
					SubmeterBackground()
						.background(.chronometer.background)
						.foreground(.chronometer.foreground)
						.frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
						.offset(y: geometry.size.height / 4)
				}
				
				ClockHands(
					dateOfMonth: dateOfMonth, day: day,
					hour: hour, minute: minute, second: second
				)

				CenterShaft(centerShaftRadius: centerShaftRadius)
			}
		}
		.onChange(of: date) { date in
			let dateOfMonth = date.get(.day) - 1
			let day = date.get(.weekday) - 1
			let hour = date.get(.hour)
			let minute = date.get(.minute)
			let second = date.get(.second)
			let nanosecond = date.get(.nanosecond)
			
			withAnimation(.linear(duration: 3)) {
				self.dateOfMonth = Double(dateOfMonth)
				self.day = Double(day)
			}

			withAnimation(self.hour == 24 && hour == 0 ? .none : .default) {
				self.hour = hour == 0 && second < 1
					? 24
					: Double(hour) + (Double(minute) + Double(second) / 60) / 60
			}

			withAnimation(self.minute == 60 && minute == 0 ? .none : .default) {
				self.minute = minute == 0 && second < 1
					? 60
					: Double(minute) + Double(second) / 60
			}

			withAnimation(self.second == 60 && second == 0 ? .none : .default) {
				self.second = second == 0 && nanosecond < 500000000
					? 60
					: Double(second)
			}
		}
		.onChange(of: batteryInfo) { _batteryInfo in
			withAnimation(.linear(duration: 5)) {
				self.batteryLevel = _batteryInfo.level
				self.batteryState = _batteryInfo.state
			}
		}
    }
}

private class ContentViewModel: ObservableObject {
	@Published var date: Date = .now
	@Published var batteryInfo: BatteryInfo = BatteryInfo(level: 0.5, state: .unknown)

	var cancellable: AnyCancellable?
	
	func startTimer() {}
}

private class ContentViewModel1: ContentViewModel {
	private var counter: Int = 0
	private var offsetDate: Date = Date(timeIntervalSince1970: 1662229850)
	private var baseDate: Date = .now

	override func startTimer() {
		cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] time in
				guard let self = self else {
					return
				}
				
				if (self.counter == 0) {
					self.baseDate = time
				}
				
				self.date = Date(timeIntervalSince1970: self.offsetDate.timeIntervalSince1970 + time.timeIntervalSince1970 - self.baseDate.timeIntervalSince1970)

				self.counter = self.counter == 200 ? 0 : self.counter + 1
			}
	}
}

private class ContentViewModel2: ContentViewModel {
	private var counter: Int = 0
	private var offsetDate: Date = Date(timeIntervalSince1970: 1662231590)
	private var baseDate: Date = .now

	override func startTimer() {
		cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] time in
				guard let self = self else {
					return
				}
				
				if (self.counter == 0) {
					self.baseDate = time
				}
				
				self.date = Date(timeIntervalSince1970: self.offsetDate.timeIntervalSince1970 + time.timeIntervalSince1970 - self.baseDate.timeIntervalSince1970)

				self.counter = self.counter == 200 ? 0 : self.counter + 1
			}
	}
}

private class ContentViewModel3: ContentViewModel {
	private var counter: Int = 0
	private var offsetDate: Date = Date(timeIntervalSince1970: 1662303590)
	private var baseDate: Date = .now

	override func startTimer() {
		cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] time in
				guard let self = self else {
					return
				}
				
				if (self.counter == 0) {
					self.baseDate = time
				}
				
				self.date = Date(timeIntervalSince1970: self.offsetDate.timeIntervalSince1970 + time.timeIntervalSince1970 - self.baseDate.timeIntervalSince1970)

				self.counter = self.counter == 200 ? 0 : self.counter + 1
			}
	}
}

private class ContentViewModel4: ContentViewModel {
	private var counter: Int = 0
	private var offsetDate: Date = Date(timeIntervalSince1970: 1662260390)
	private var baseDate: Date = .now

	override func startTimer() {
		cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] time in
				guard let self = self else {
					return
				}
				
				if (self.counter == 0) {
					self.baseDate = time
				}
				
				self.date = Date(timeIntervalSince1970: self.offsetDate.timeIntervalSince1970 + time.timeIntervalSince1970 - self.baseDate.timeIntervalSince1970)

				self.counter = self.counter == 200 ? 0 : self.counter + 1
			}
	}
}

private struct ChronometerView_Preview: View {
	@ObservedObject private var viewModel: ContentViewModel

	init(viewModel: ContentViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		ChronometerView(date: $viewModel.date, batteryInfo: $viewModel.batteryInfo)
			.padding(.all, 10)
			.frame(width: 500, height: 500)
			.onAppear {
				viewModel.startTimer()
			}
	}
}

struct ChronometerView_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			ChronometerView_Preview(viewModel: ContentViewModel1())
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
		
		ZStack {
			ChronometerView_Preview(viewModel: ContentViewModel2())
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
		
		ZStack {
			ChronometerView_Preview(viewModel: ContentViewModel3())
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
		
		ZStack {
			ChronometerView_Preview(viewModel: ContentViewModel4())
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
