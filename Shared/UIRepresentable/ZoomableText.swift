//
//  ZoomableText.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/1/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI
import UIKit

struct ZoomableText: UIViewRepresentable {
    var text: String
    var frame: CGRect
    private let zoomLabel = UILabel()

    func makeUIView(context: Context) -> UIScrollView {
        // configure scroll view
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 5
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .white

        // configure scroll view content
        zoomLabel.font = AsciiArtist.font
        zoomLabel.lineBreakMode = NSLineBreakMode.byClipping
        zoomLabel.numberOfLines = 0
        zoomLabel.text = text
        zoomLabel.textColor = .black
        zoomLabel.sizeToFit()
        zoomLabel.accessibilityLabel = "ASCII Art"

        // add content to scroll view
        scrollView.addSubview(zoomLabel)
        scrollView.contentSize = zoomLabel.frame.size
        setMinZoom(scrollView: scrollView) // must be after so it knows content size

        return scrollView
    }

    private func setMinZoom(scrollView: UIScrollView) {
        let scrollSize  = frame.size
        let contentSize = scrollView.contentSize
        let scaleWidth  = scrollSize.width / contentSize.width
        let scaleHeight = scrollSize.height / contentSize.height
        let scale       = max(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: false)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: ZoomableText

        init(_ parent: ZoomableText) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.zoomLabel
        }
    }

}
