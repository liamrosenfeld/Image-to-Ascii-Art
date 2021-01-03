//
//  String+Image.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/2/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

#if os(iOS)
import UIKit

extension String {
    func toImage(withFont font: UIFont) -> UIImage {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: font
        ]
        let textSize = self.size(withAttributes: attributes).roundedUp

        UIGraphicsBeginImageContextWithOptions(textSize, true, 0)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: textSize))

        self.draw(at: CGPoint.zero, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}

#elseif os(macOS)
import AppKit

extension String {
    func toImage(withFont font: NSFont) -> NSImage {
        // Assemble attributes
        let attributes = [
            NSAttributedString.Key.foregroundColor: NSColor.black,
            NSAttributedString.Key.font: font
        ]
        let textSize = self.size(withAttributes: attributes).roundedUp
        
        // Get context
        NSGraphicsContext.saveGraphicsState()
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(textSize.width),
            pixelsHigh: Int(textSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        
        // Color background white
        NSColor.white.setFill()
        let backgroundRect = NSRect(origin: CGPoint.zero, size: textSize)
        NSBezierPath.fill(backgroundRect)
        
        // Draw string
        self.draw(at: CGPoint.zero, withAttributes: attributes)
        
        // Restore context
        NSGraphicsContext.restoreGraphicsState()
        
        // Export to image
        let image = NSImage(size: textSize)
        image.addRepresentation(rep)
        image.size = textSize
        return image
    }
}
#endif
