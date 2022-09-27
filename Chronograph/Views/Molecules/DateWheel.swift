//
//  DateWheel.swift
//  Chronograph
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

public struct DateWheel: View {
	static let degreeOfDay: Double = 360.0 / 31.0
	
	private var backgroundColor: Color = .black
	private var dateColor: Color = .gray

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
			.foregroundColor(dateColor.opacity(0.5))

			ForEach(1..<32) { date in
				VStack {
					ZStack {
						Text("\(date)")
							.font(.system(size: 18))
							.fontWeight(.bold)
							.rotationEffect(.degrees(-90))
							.foregroundColor(dateColor)
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

public extension DateWheel {
	func background(_ color: Color) -> Self {
		var _self = self
		_self.backgroundColor = color
		return _self
	}
	
	func date(_ color: Color) -> Self {
		var _self = self
		_self.dateColor = color
		return _self
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
