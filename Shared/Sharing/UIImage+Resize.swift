//
//  UIImage+Resize.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/31/20.
//

import UIKit
import AVFoundation

extension UIImage {
    func resize(to destSize: CGSize) -> UIImage {
        let image = self.cgImage!
        let rect = CGRect(origin: .zero, size: destSize)
        
        guard let context = CGContext(
            data: nil,
            width: Int(destSize.width),
            height: Int(destSize.height),
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: Int(destSize.width) * image.numComponents,
            space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: image.bitmapInfo.rawValue
        ) else {
            print("Error: Failed to make context")
            return UIImage(named: "Logo")!
        }
        
        context.draw(image, in: rect)
        let scaledImage = context.makeImage()!
        return UIImage(cgImage: scaledImage)
    }
    
    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if !isTooBig {
            return self
        }
        
        let maxRect    = CGRect(origin: CGPoint.zero, size: maxSize)
        let scaledRect = AVMakeRect(aspectRatio: self.size, insideRect: maxRect)
        let scaledSize = scaledRect.size
        return self.resize(to: scaledSize)
    }
}

extension CGImage {
    var numComponents: Int {
        let bytesPerComponent = Int(self.bitsPerComponent / 8)
        return (self.bytesPerRow / bytesPerComponent) / self.width
    }
}
