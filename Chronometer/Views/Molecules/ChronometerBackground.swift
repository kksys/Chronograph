//
//  ChronometerBackground.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/17.
//

import SwiftUI

struct ChronometerBackground: View {
	let offsetWindowOfDay: CGFloat = 160
	let widthWindowOfDay: CGFloat = 90
	let heightWindowOfDay: CGFloat = 20
	let radiusWindowOfDay: CGFloat = 8

    var body: some View {
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
					path.addPath(
						Path(
							roundedRect:
								CGRect(
									x: geometry.size.width / 2 - offsetWindowOfDay,
									y: -heightWindowOfDay / 2,
									width: widthWindowOfDay,
									height: heightWindowOfDay
								),
							cornerRadius: radiusWindowOfDay
						)
						.applying(
							.init(rotationAngle: 0.0 / 180.0 * Double.pi)
							.concatenating(
								.init(
									translationX: geometry.size.width / 2,
									y: geometry.size.height / 2
								)
							)
						)
					)
				}
				.fill(style: FillStyle(eoFill: true))
				.foregroundColor(.black)

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
				.stroke(style: .init(lineWidth: 1))
				.rotationEffect(.degrees(-90))
				.foregroundColor(.gray)

				Path(roundedRect:
					CGRect(
						x: geometry.size.width / 2 - offsetWindowOfDay,
						y: -heightWindowOfDay / 2,
						width: widthWindowOfDay,
						height: heightWindowOfDay
					),
					cornerRadius: radiusWindowOfDay
				)
				.applying(
					.init(rotationAngle: 0.0 / 180.0 * Double.pi)
					.concatenating(
						.init(
							translationX: geometry.size.width / 2,
							y: geometry.size.height / 2
						)
					)
				)
				.stroke(style: .init(lineWidth: 1))
				.foregroundColor(.gray)

				ForEach(0..<12) { index in
					HourScaleShape()
						.strokeAndFill(
							Color.gray,
							strokeStyle: .init(lineWidth: 1)
						)
						.clipped(antialiased: true)
						.rotationEffect(.degrees(30 * Double(index)))
				}
				
				ForEach(0..<60) { index in
					MinuteScaleShape()
						.strokeAndFill(
							Color.gray,
							strokeStyle: .init(lineWidth: 1)
						)
						.clipped(antialiased: true)
						.rotationEffect(.degrees(6 * Double(index)))
				}
			}
		}
    }
}

struct ChronometerBackground_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			ChronometerBackground()
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
