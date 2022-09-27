//
//  ContentView.swift
//  Example
//
//  Created by KK Systems on 2022/09/18.
//

import Chronograph
import Combine
import SwiftUI

struct ContentView: View {
	static let defaultWidth: CGFloat = 500
#if os(iOS) || os(watchOS) || os(tvOS)
	static let minWidth: CGFloat = 0
#elseif os(macOS)
	static let minWidth: CGFloat = 375
#endif
	let defaultWidth: CGFloat = ContentView.defaultWidth
	let minWidth: CGFloat = ContentView.minWidth
	
	@ObservedObject private var viewModel: BaseContentViewModel

	init(viewModel: BaseContentViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		GeometryReader { geometry in
			let width = geometry.size.width
			let height = geometry.size.height
			let idealWidth = max(min(width, height), minWidth)
			let scale = idealWidth >= minWidth
				? idealWidth / defaultWidth
				: 1
			
			ChronographView(
				date: $viewModel.date,
				batteryInfo: $viewModel.batteryInfo
			)
				.padding(.all, 10)
				.frame(width: defaultWidth, height: defaultWidth)
				.scaleEffect(scale, anchor: .zero)
				.offset(
					x: (width - idealWidth) / 2,
					y: (height - idealWidth) / 2
				)
				.onAppear {
					viewModel.startTimer()
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						viewModel.subscribeBattery()
					}
				}
				.onDisappear {
					viewModel.unsubscribeBattery()
				}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			ContentView(viewModel: ContentViewModel())
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
		
		ZStack {
			ContentView(viewModel: ContentViewModelForScreenshot())
				.padding(.all, 10)
		}
		.frame(width: 500, height: 500)
		.previewLayout(.fixed(width: 500, height: 500))
	}
}
