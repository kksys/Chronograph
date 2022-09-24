//
//  ExampleApp.swift
//  Example
//
//  Created by KK Systems on 2022/09/21.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
			ContentView(viewModel: ContentViewModel())
				.frame(
					minWidth: ContentView.minWidth, idealWidth: ContentView.minWidth, maxWidth: .infinity,
					minHeight: ContentView.minWidth, idealHeight: ContentView.minWidth, maxHeight: .infinity
				)
				.edgesIgnoringSafeArea(.all)
        }
#if os(macOS)
		.windowStyle(.hiddenTitleBar)
#endif
    }
}
