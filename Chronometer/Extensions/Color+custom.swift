//
//  Color+custom.swift
//  Chronometer
//
//  Created by KK Systems on 2022/09/25.
//

import SwiftUI

public extension Color {
	typealias chronometer = ChronometerTheme
	
	struct ChronometerTheme {
		private class DummyClass {}
		private static let frameworkBundle: Bundle = Bundle(for: type(of: DummyClass()))
		
		public static let background: Color = Color("background", bundle: Self.frameworkBundle)
		public static let foreground: Color = Color("foreground", bundle: Self.frameworkBundle)
	}
}
