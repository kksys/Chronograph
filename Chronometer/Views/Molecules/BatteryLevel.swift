//
//  BatteryLevel.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

struct BatteryLevelGauge: Shape {
	func path(in rect: CGRect) -> Path {
		let width: CGFloat = 1
		var path = Path()
		
		path.addRect(CGRect(
			x: (rect.size.width - width) / 2,
			y: rect.size.height / 32,
			width: width,
			height: rect.size.height / 12
		))
		
		return path
	}
}

struct BatteryZoneShape: Shape {
	var rangeAngle: Angle
	
	func path(in rect: CGRect) -> Path {
		let center = CGPoint(
			x: rect.size.width / 2,
			y: rect.size.height / 2
		)
		var path = Path()

		path.move(to: CGPoint(
			x: rect.size.width * (1 - (1 / 32.0 + 1 / 24.0)),
			y: rect.size.width / 2
		))
		path.addArc(
			center: center,
			radius: rect.size.height * (1 / 2 - 1 / 32),
			startAngle: .degrees(0),
			endAngle: rangeAngle,
			clockwise: false
		)
		path.addArc(
			center: center,
			radius: rect.size.height * (1 / 2.0 - (1 / 32.0 + 1 / 24.0)),
			startAngle: rangeAngle,
			endAngle: .degrees(0),
			clockwise: true
		)
		path.closeSubpath()
		
		return path
	}
}

public struct BatteryLevel: View {
	var level: Double
	var state: BatteryState
	
	private var backgroundColor: Color = .black
	private var foregroundColor: Color = .gray
	private var batteryZoneDangerColor: Color = .red
	private var batteryZoneWarningColor: Color = .yellow
	private var batteryZoneGoodColor: Color = .green
	private var batteryZoneDangerRange: ClosedRange<Double> = 0.0...0.2
	private var batteryZoneWarningRange: ClosedRange<Double> = 0.2...0.7
	private var batteryZoneGoodRange: ClosedRange<Double> = 0.7...1.0

	let angleRange: Angle = .degrees(160)

	var batteryStateIcon: String {
		switch state {
		case .unknown:
			return "questionmark"
		case .charging:
			return "bolt"
		case .full:
			return "bolt.fill"
		default:
			return ""
		}
	}

	public init(level: Double, state: BatteryState) {
		self.level = level
		self.state = state
	}
	
	func calculateBatteryHandRect(geometry: GeometryProxy) -> CGRect {
		return CGRect(
			x: geometry.size.width / 2,
			y: geometry.size.height / 2,
			width: 6,
			height: geometry.size.height * (1 / 2 - 1 / 32)
		)
	}

	public var body: some View {
		GeometryReader { geometry in
			let batteryHandRect = calculateBatteryHandRect(geometry: geometry)

			ZStack {
				Path { path in
					path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2), radius: geometry.size.height / 2, startAngle: .degrees(-110), endAngle: .degrees(110), clockwise: false
					)
					path.closeSubpath()
				}
				.fill(style: FillStyle(eoFill: true))
				.rotationEffect(.degrees(-90))
				.foregroundColor(backgroundColor)

				Path { path in
					path.addArc(
						center: CGPoint(
							x: geometry.size.width / 2,
							y: geometry.size.height / 2
						),
						radius: geometry.size.height / 2,
						startAngle: .degrees(-110),
						endAngle: .degrees(110),
						clockwise: false
					)
					path.closeSubpath()
				}
				.stroke(style: .init(lineWidth: 1))
				.rotationEffect(.degrees(-90))
				.foregroundColor(foregroundColor)
				
				Group {
					BatteryZoneShape(
						rangeAngle: .degrees(angleRange.degrees * (batteryZoneDangerRange.upperBound - batteryZoneDangerRange.lowerBound))
					)
						.strokeAndFill(
							batteryZoneDangerColor,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(.degrees(-angleRange.degrees * (0.5 - batteryZoneDangerRange.lowerBound) - 90))
					
					BatteryZoneShape(
						rangeAngle: .degrees(angleRange.degrees * (batteryZoneWarningRange.upperBound - batteryZoneWarningRange.lowerBound))
					)
						.strokeAndFill(
							batteryZoneWarningColor,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(.degrees(-angleRange.degrees * (0.5 - batteryZoneWarningRange.lowerBound) - 90))
					
					BatteryZoneShape(
						rangeAngle: .degrees(angleRange.degrees * (batteryZoneGoodRange.upperBound - batteryZoneGoodRange.lowerBound))
					)
						.strokeAndFill(
							batteryZoneGoodColor,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(.degrees(-angleRange.degrees * (0.5 - batteryZoneGoodRange.lowerBound) - 90))
				}

				ForEach(0..<11) { level in
					BatteryLevelGauge()
						.strokeAndFill(
							foregroundColor,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(
							.degrees(angleRange.degrees * (Double(level) / 10 - 0.5))
						)
						.foregroundColor(foregroundColor)
				}

				Text("E")
					.foregroundColor(foregroundColor)
					.offset(x: -(geometry.size.width / 2 - geometry.size.width / 8), y: geometry.size.height / 20)

				if (state != .unplugged) {
					Image(systemName: batteryStateIcon)
						.foregroundColor(foregroundColor)
						.offset(
							y: -(geometry.size.height / 2 - geometry.size.height / 4.5)
						)
				}

				Image(systemName: "battery.100")
					.foregroundColor(foregroundColor)
					.offset(
						y: -(geometry.size.height / 2 - geometry.size.height / 2.75)
					)

				Text("F")
					.foregroundColor(foregroundColor)
					.offset(x: (geometry.size.width / 2 - geometry.size.width / 8), y: geometry.size.height / 20)

				Group {
					SecondClockHand(
						width: batteryHandRect.width,
						height: batteryHandRect.height,
						projectionHeight: batteryHandRect.height / 4
					)
					.foregroundColor(.gray.opacity(0.7))
					.blur(radius: 1)
					.offset(x: geometry.size.width / 2, y: geometry.size.height / 2 + 2)
					.rotationEffect(.degrees(angleRange.degrees * (level - 0.5)))
					.offset(x: 0, y: 3)
					
					SecondClockHand(
						width: batteryHandRect.width,
						height: batteryHandRect.height,
						projectionHeight: batteryHandRect.height / 4
					)
					.foregroundColor(.orange)
					.offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
					.rotationEffect(.degrees(angleRange.degrees * (level - 0.5)))
				}

				CenterShaft(centerShaftRadius: 12)
			}
		}
	}
}

public extension BatteryLevel {
	func background(_ color: Color) -> Self {
		var _self = self
		_self.backgroundColor = color
		return _self
	}
	
	func foreground(_ color: Color) -> Self {
		var _self = self
		_self.foregroundColor = color
		return _self
	}
	
	func batteryZoneDanger(color: Color) -> Self {
		var _self = self
		_self.batteryZoneDangerColor = color
		return _self
	}
	
	func batteryZoneWarning(color: Color) -> Self {
		var _self = self
		_self.batteryZoneWarningColor = color
		return _self
	}
	
	func batteryZoneGood(color: Color) -> Self {
		var _self = self
		_self.batteryZoneGoodColor = color
		return _self
	}
	
	func batteryZoneDanger(range: ClosedRange<Double>) -> Self {
		var _self = self
		_self.batteryZoneDangerRange = range
		return _self
	}
	
	func batteryZoneWarning(range: ClosedRange<Double>) -> Self {
		var _self = self
		_self.batteryZoneWarningRange = range
		return _self
	}
	
	func batteryZoneGood(range: ClosedRange<Double>) -> Self {
		var _self = self
		_self.batteryZoneGoodRange = range
		return _self
	}
}

struct BatteryLevel_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			BatteryLevel(level: 100, state: .unknown)
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
