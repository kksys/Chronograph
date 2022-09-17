//
//  CenterShaft.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/18.
//

import SwiftUI

struct CenterShaft: View {
	var centerShaftRadius: CGFloat
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Path { path in
					path.addEllipse(in: CGRect(x: (geometry.size.width - centerShaftRadius) / 2, y: (geometry.size.height - centerShaftRadius) / 2, width: centerShaftRadius, height: centerShaftRadius))
				}
				.stroke()
				.foregroundColor(.black)

				Path { path in
					path.addEllipse(in: CGRect(x: (geometry.size.width - centerShaftRadius) / 2, y: (geometry.size.height - centerShaftRadius) / 2, width: centerShaftRadius, height: centerShaftRadius))
				}
				.fill()
				.foregroundColor(.gray)
			}
		}
	}
}

struct CenterShaft_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			CenterShaft(centerShaftRadius: 12)
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
    }
}
