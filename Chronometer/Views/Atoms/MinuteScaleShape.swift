//
//  MinuteScaleShape.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

struct MinuteScaleShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.addRect(
			CGRect(
				x: rect.size.width / 2 - 1,
				y: 10,
				width: 2,
				height: 20
			)
		)

		return path
	}
}

struct MinuteSubScaleShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.addRect(
			CGRect(
				x: rect.size.width / 2 - 1,
				y: 10,
				width: 2,
				height: 10
			)
		)

		return path
	}
}
