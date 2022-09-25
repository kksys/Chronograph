//
//  DayWheel.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/17.
//

import SwiftUI

enum Day: Int, CaseIterable, Identifiable {
	case Sunday = 0
	case Monday = 1
	case Tuesday = 2
	case Wednesday = 3
	case Thursday = 4
	case Friday = 5
	case Saturday = 6

	var id: Int { rawValue }
	
	var dayString: String {
		return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][id]
	}
	
	static var count: Int {
		Day.allCases.count
	}
}

public struct DayWheel: View {
	static let degreeOfDay: Double = 360.0 / 35.0
	
	private var backgroundColor: Color = .black
	private var dayColor: Color = .gray
	private var sundayColor: Color = .red
	private var saturdayColor: Color = .blue

	private func dayTextColor(day: Day) -> Color {
		switch day {
		case .Sunday:
			return sundayColor
		case .Saturday:
			return saturdayColor
		default:
			return dayColor
		}
	}
	
	public var body: some View {
		GeometryReader { geometry in
			Path { path in
				path.addEllipse(
					in: CGRect(
						x: 0,
						y: 0,
						width: geometry.size.width,
						height: geometry.size.height
					)
				)
			}
			.fill(backgroundColor)

			Path { path in
				path.addEllipse(
					in: CGRect(
						x: 0,
						y: 0,
						width: geometry.size.width,
						height: geometry.size.height
					)
				)
			}
			.stroke(style: .init(lineWidth: 2))
			.foregroundColor(dayColor.opacity(0.5))

			ForEach(Day.allCases) { day in
				VStack {
					ZStack {
						Text(day.dayString.prefix(3))
							.font(.system(size: 18))
							.fontWeight(.bold)
							.rotationEffect(.degrees(-90))
							.foregroundColor(dayTextColor(day: day))
					}
					.frame(width: geometry.size.width, height: 50)
					Spacer()
				}
				.frame(width: geometry.size.width, height: geometry.size.height)
				.rotationEffect(.degrees(DayWheel.degreeOfDay * Double(day.rawValue) + 90.0))
			}
		}
    }
}

public extension DayWheel {
	func background(_ color: Color) -> Self {
		var _self = self
		_self.backgroundColor = color
		return _self
	}
	
	func day(_ color: Color) -> Self {
		var _self = self
		_self.dayColor = color
		return _self
	}
	
	func sunday(_ color: Color) -> Self {
		var _self = self
		_self.sundayColor = color
		return _self
	}
	
	func saturday(_ color: Color) -> Self {
		var _self = self
		_self.saturdayColor = color
		return _self
	}
}

struct DayWheel_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			DayWheel()
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
