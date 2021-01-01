//
//  SysImage.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 1/1/21.
//  Copyright © 2021 liamrosenfeld. All rights reserved.
//

import Accelerate.vImage

#if os(iOS)
import UIKit
typealias SysImage = UIImage

extension UIImage {
    func makeBuffer() -> vImage_Buffer {
        // Put the image right way up
        let rotatedImage = self.fixedOrientation()
        
        // Get RGBA buffer for resizing operations
        // also normalizes image format to RGBA8888
        return rotatedImage.cgImage!.toRGBABuffer()
    }
}

#elseif os(macOS)
import AppKit
typealias SysImage = NSImage

extension NSImage {
    func makeBuffer() -> vImage_Buffer {
        // Get RGBA buffer for resizing operations
        // also normalizes image format to RGBA8888
        return self.cgImage!.toRGBABuffer()
    }
    
    var cgImage: CGImage? {
        var imageRect = CGRect(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }
}
#endif
