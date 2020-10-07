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
    // MARK: - Properties
    var text: String
    var size: CGSize
    private let scrollView = UIScrollView()
    private let zoomLabel = UILabel()
    
    // MARK: - Lifecycle
    func makeUIView(context: Context) -> UIScrollView {
        // configure views with basic settings
        configScroll(coordinator: context.coordinator)
        configLabel()
        
        // put label inside scroll
        scrollView.addSubview(zoomLabel)
        
        // add content to scroll view
        update(scrollView)

        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        update(uiView)
    }
    
    // MARK: - UIView Actions
    private func configScroll(coordinator: Coordinator) {
        scrollView.maximumZoomScale = 5
        scrollView.delegate = coordinator
        scrollView.backgroundColor = .white
    }
    
    private func configLabel() {
        zoomLabel.font = AsciiArtist.font
        zoomLabel.lineBreakMode = .byClipping
        zoomLabel.numberOfLines = 0
        zoomLabel.textColor = .black
        zoomLabel.accessibilityLabel = "ASCII Art"
    }
    
    private func update(_ scrollView: UIScrollView) {
        zoomLabel.text = text
        zoomLabel.sizeToFit()
        scrollView.contentSize = contentSize
        setMinZoom(for: scrollView) // must be after everything so it knows content size
    }
    
    private var contentSize: CGSize {
        // `zoomLabel.frame.size` returns
        // the size without any line breaks
        // so this workaround is necessary
        let attributedText = NSAttributedString(string: text, attributes: [.font: AsciiArtist.font])
        let constraintBox = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(
            with: constraintBox,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return rect.size
    }

    private func setMinZoom(for scrollView: UIScrollView) {
        // on the initial view load the geometry reader passes frame of zero
        if !size.width.isZero && !size.height.isZero {
            let contentSize = scrollView.contentSize
            let scaleWidth  = size.width / contentSize.width
            let scaleHeight = size.height / contentSize.height
            let fillScale   = max(scaleWidth, scaleHeight)
            let fitScale    = min(scaleWidth, scaleHeight)
            scrollView.minimumZoomScale = fitScale
            scrollView.zoomScale = fillScale
        }
    }

    // MARK: - Coordinator
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
