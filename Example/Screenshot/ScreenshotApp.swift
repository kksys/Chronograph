//
//  ScreenshotApp.swift
//  Screenshot
//
//  Created by KK Systems on 2022/09/22.
//

import SwiftUI

@main
struct ScreenshotApp: App {
	let snapshotRatio: CGFloat = 2

    var body: some Scene {
        WindowGroup {
			Snapshot {
				ContentView(viewModel: ContentViewModelForScreenshot())
					.frame(
						minWidth: ContentView.minWidth, idealWidth: .infinity,
						minHeight: ContentView.minWidth, idealHeight: .infinity
					)
					.background(
						Circle()
							.fill(Color.chronometer.background)
							.padding(.all, 20)
					)
			}
			.edgesIgnoringSafeArea(.all)
			.frame(
				width: ContentView.defaultWidth * snapshotRatio,
				height: ContentView.defaultWidth * snapshotRatio
			)
			.onAppear {}
        }
#if os(macOS)
		.windowStyle(.hiddenTitleBar)
#endif
    }
}
