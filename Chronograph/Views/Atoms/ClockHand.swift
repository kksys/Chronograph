//
//  ClockHand.swift
//  Chronograph
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

struct ClockHand: View {
	var width: CGFloat
	var height: CGFloat
	
    var body: some View {
		Path { path in
			path.move(to: CGPoint(x: -width / 2, y: 0))
			path.addLine(to: CGPoint(x: -width / 2 + width / 4, y: -height))
			path.addLine(to: CGPoint(x: width / 2 - width / 4, y: -height))
			path.addLine(to: CGPoint(x: width / 2, y: 0))
			path.closeSubpath()
		}
    }
}

struct ClockHand_Previews: PreviewProvider {
    static var previews: some View {
		ClockHand(width: 4, height: 50)
    }
}
