//
//  SubmeterBackground.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

public struct SubmeterBackground: View {
	private var backgroundColor: Color = .black
	private var foregroundColor: Color = .gray

	public var body: some View {
		GeometryReader { (geometry: GeometryProxy) in
			ZStack {
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
				.fill(backgroundColor, style: FillStyle(eoFill: true))

				Path { path in
					path.addArc(
						center: CGPoint(
							x: geometry.size.width / 2,
							y: geometry.size.height / 2
						),
						radius: geometry.size.width / 2,
						startAngle: .zero,
						endAngle: .degrees(360),
						clockwise: false
					)
				}
				.stroke(foregroundColor, style: .init(lineWidth: 1))
				.rotationEffect(.degrees(-90))

				ForEach(0..<12) { index in
					HourSubScaleShape()
						.stroke(foregroundColor, style: .init(lineWidth: 1))
						.background(HourSubScaleShape().fill(foregroundColor))
						.clipped(antialiased: true)
						.rotationEffect(.degrees(30 * Double(index)))
				}
				
				ForEach(0..<60) { index in
					MinuteSubScaleShape()
						.stroke(foregroundColor, style: .init(lineWidth: 1))
						.background(MinuteSubScaleShape().fill(foregroundColor))
						.clipped(antialiased: true)
						.rotationEffect(.degrees(6 * Double(index)))
				}
			}
		}
    }
}

public extension SubmeterBackground {
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
}

struct SubmeterBackground_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			SubmeterBackground()
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
