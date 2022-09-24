//
//  DateWheel.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

struct DateWheel: View {
	static let degreeOfDay: Double = 360.0 / 31.0
	
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

			ForEach(1..<32) { date in
				VStack {
					ZStack {
						Text("\(date)")
							.font(.system(size: 18))
							.fontWeight(.bold)
							.rotationEffect(.degrees(-90))
							.foregroundColor(.gray)
					}
					.frame(width: geometry.size.width, height: 40)
					Spacer()
				}
				.frame(width: geometry.size.width, height: geometry.size.height)
				.rotationEffect(.degrees(DateWheel.degreeOfDay * Double(date) + 90.0 - DateWheel.degreeOfDay * 1.0))
			}
		}
	}
}

struct DateWheel_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			DateWheel()
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
