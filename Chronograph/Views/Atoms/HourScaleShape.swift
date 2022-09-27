//
//  HourScaleShape.swift
//  Chronograph
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

struct HourScaleShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.addRect(
			CGRect(
				x: rect.size.width / 2 - 2,
				y: 10,
				width: 4,
				height: 50
			)
		)

		return path
	}
}

struct HourSubScaleShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.addRect(
			CGRect(
				x: rect.size.width / 2 - 2,
				y: 10,
				width: 4,
				height: 20
			)
		)

		return path
	}
}
