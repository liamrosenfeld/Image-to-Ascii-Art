//
//  ZoomableText.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 12/29/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI
import AppKit

struct ZoomableText: NSViewRepresentable {
    // MARK: - Properties
    var text: String
    var size: CGSize
    private let scrollView = NSScrollView()
    private let textView = NSTextView()
    
    static let maxZoom: CGFloat = 4
    
    @Binding var zoom: CGFloat
    
    // MARK: - Lifecycle
    func makeNSView(context: Context) -> NSScrollView {
        // configure views with basic settings
        configScroll()
        configLabel()
        
        // put label inside scroll
        scrollView.documentView = textView
        
        // add content to scroll view
        update(scrollView)
        
        return scrollView
    }
    
    func updateNSView(_ uiView: NSScrollView, context: Context) {
        update(uiView)
    }
    
    // MARK: - Creation
    private func configScroll() {
        scrollView.allowsMagnification = true
        scrollView.maxMagnification = Self.maxZoom
        scrollView.backgroundColor = .white
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
    }
    
    private func configLabel() {
        // appearance
        textView.font = AsciiArtist.font
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.drawsBackground = true
        textView.isSelectable = false
        textView.setAccessibilityLabel("ASCII Art")
        
        // sizing
        textView.frame = NSRect(origin: .zero, size: contentSize)
        textView.textContainerInset = .zero
        textView.maxSize = contentSize
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = .width
        textView.textContainer?.containerSize = contentSize
        textView.textContainer?.widthTracksTextView = true
        print(textView.frame)
    }
    
    private var contentSize: CGSize {
        let attributedText = NSAttributedString(string: text, attributes: [.font: AsciiArtist.font])
        let constraintBox = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(
            with: constraintBox,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return rect.size
    }
    
    // MARK: - Updating
    private func update(_ scrollView: NSScrollView) {
        textView.string = text
        scrollView.minMagnification = minMag // must be after everything so it knows content size
        scrollView.magnification = zoomToMag(zoom)
    }
    
    private var minMag: CGFloat {
        let textSize    = contentSize
        let scaleWidth  = size.width / textSize.width
        let scaleHeight = size.height / textSize.height
        let fitScale    = min(scaleWidth, scaleHeight)
        return fitScale
    }
    
    /// 0...max -> min...max
    private func zoomToMag(_ zoom: CGFloat) -> CGFloat {
        //               (max2 - min2)(num - min1)
        // scale(num) = ---------------------------- + min2
        //                     max1 - min1
        //
        // special case
        // where max1 = max2 and min1 = 0:
        //
        //               (max2 - min2)(num)
        // scale(num) = --------------------- + min2
        //                     max1
        return (((Self.maxZoom - minMag) * zoom) / Self.maxZoom) + minMag
    }
    
    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: ZoomableText
        var notification: NSObjectProtocol = NSObject()
        
        init(_ parent: ZoomableText) {
            self.parent = parent
            super.init()
            setNotifications()
        }
        
        func setNotifications() {
            self.notification = NotificationCenter.default.addObserver(
                forName: NSScrollView.didEndLiveMagnifyNotification,
                object: nil,
                queue: nil)
            { [unowned self] notification in
                self.parent.zoom = self.parent.scrollView.magnification
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(notification)
        }
    }
}
