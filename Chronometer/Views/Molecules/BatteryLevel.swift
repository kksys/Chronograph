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

struct BatteryLevel: View {
	var level: Double
	var state: BatteryState
	
	let batteryZoneColorDanger: Color = .red
	let batteryZoneColorWarning: Color = .yellow
	let batteryZoneColorGood: Color = .green
	
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

	func calculateBatteryHandRect(geometry: GeometryProxy) -> CGRect {
		return CGRect(
			x: geometry.size.width / 2,
			y: geometry.size.height / 2,
			width: 6,
			height: geometry.size.height * (1 / 2 - 1 / 32)
		)
	}

	var body: some View {
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
				.foregroundColor(.black)

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
				.foregroundColor(.gray)
				
				Group {
					BatteryZoneShape(
						rangeAngle: .degrees(angleRange.degrees / 10 * 2)
					)
						.strokeAndFill(
							batteryZoneColorDanger,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(.degrees(-angleRange.degrees / 10 * 5 - 90))
					
					BatteryZoneShape(
						rangeAngle: .degrees(angleRange.degrees / 10 * 5)
					)
						.strokeAndFill(
							batteryZoneColorWarning,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(.degrees(-angleRange.degrees / 10 * 3 - 90))
					
					BatteryZoneShape(
						rangeAngle: .degrees(angleRange.degrees / 10 * 3)
					)
						.strokeAndFill(
							batteryZoneColorGood,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(.degrees(angleRange.degrees / 10 * 2 - 90))
				}

				ForEach(0..<11) { level in
					BatteryLevelGauge()
						.strokeAndFill(
							Color.gray,
							strokeStyle: .init(lineWidth: 1)
						)
						.rotationEffect(
							.degrees(angleRange.degrees * (Double(level) / 10 - 0.5))
						)
						.foregroundColor(.gray)
				}

				Text("E")
					.offset(x: -(geometry.size.width / 2 - geometry.size.width / 8), y: geometry.size.height / 20)

				if (state != .unplugged) {
					Image(systemName: batteryStateIcon)
						.offset(
							y: -(geometry.size.height / 2 - geometry.size.height / 4.5)
						)
				}

				Image(systemName: "battery.100")
					.offset(
						y: -(geometry.size.height / 2 - geometry.size.height / 2.75)
					)

				Text("F")
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
