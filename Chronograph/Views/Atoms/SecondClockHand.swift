//
//  SecondClockHand.swift
//  Chronograph
//
//  Created by KK Systems on 2022/09/19.
//

import SwiftUI

struct SecondClockHand: View {
	var width: CGFloat
	var height: CGFloat
	var projectionHeight: CGFloat
	
	var body: some View {
		Path { path in
			path.move(to: CGPoint(
				x: -width / 2, y: projectionHeight
			))
			path.addLine(to: CGPoint(
				x: -width / 2 + width / 4, y: -height
			))
			path.addLine(to: CGPoint(
				x: width / 2 - width / 4, y: -height
			))
			path.addLine(to: CGPoint(
				x: width / 2, y: projectionHeight
			))
			path.closeSubpath()
		}
	}
}

struct SecondClockHand_Previews: PreviewProvider {
    static var previews: some View {
		SecondClockHand(width: 4, height: 50, projectionHeight: 25)
			.foregroundColor(.red)
			.offset(x: 2, y: 38.5)
    }
}
