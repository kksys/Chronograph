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

struct DayWheel: View {
	static let degreeOfDay: Double = 360.0 / 35.0
	
    var body: some View {
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
			.fill(.black)

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
			.foregroundColor(.gray.opacity(0.5))

			ForEach(Day.allCases) { day in
				VStack {
					ZStack {
						Text(day.dayString.prefix(3))
							.font(.system(size: 18))
							.fontWeight(.bold)
							.rotationEffect(.degrees(-90))
							.foregroundColor(day == .Sunday ? .red : day == .Saturday ? .blue : .gray)
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
