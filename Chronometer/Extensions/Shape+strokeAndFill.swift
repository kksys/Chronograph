//
//  Shape+strokeAndFill.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/20.
//

import SwiftUI

extension Shape {
	func strokeAndFill<S>(
		_ shapeStyle: S
	) -> some View where S : ShapeStyle {
		self
			.stroke(shapeStyle)
			.background(self.fill(shapeStyle))
	}

	func strokeAndFill<S>(
		_ shapeStyle: S,
		strokeStyle: StrokeStyle
	) -> some View where S : ShapeStyle {
		self
			.stroke(shapeStyle, style: strokeStyle)
			.background(self.fill(shapeStyle))
	}

	func strokeAndFill<S>(
		_ shapeStyle: S,
		fillStyle: FillStyle
	) -> some View where S : ShapeStyle {
		self
			.stroke(shapeStyle)
			.background(self.fill(shapeStyle, style: fillStyle))
	}

	func strokeAndFill<S>(
		_ shapeStyle: S,
		strokeStyle: StrokeStyle,
		fillStyle: FillStyle
	) -> some View where S : ShapeStyle {
		self
			.stroke(shapeStyle, style: strokeStyle)
			.background(self.fill(shapeStyle, style: fillStyle))
	}
}
