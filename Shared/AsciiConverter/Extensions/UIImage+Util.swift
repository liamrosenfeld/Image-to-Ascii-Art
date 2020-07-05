//
//  UIImage+Util.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

extension UIImage {
    func resize(to destSize: CGSize) -> UIImage {
        let image = self.cgImage!
        let rect = CGRect(origin: .zero, size: destSize)

        let context = CGContext(data: nil,
                                width: Int(destSize.width),
                                height: Int(destSize.height),
                                bitsPerComponent: image.bitsPerComponent,
                                bytesPerRow: Int(destSize.width) * 4, // RGBA
                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: image.bitmapInfo.rawValue)
        context?.draw(image, in: rect)

        let scaledImage = context!.makeImage()!

        return UIImage(cgImage: scaledImage)
    }

    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if isTooBig {
            let maxRect       = CGRect(origin: CGPoint.zero, size: maxSize)
            let scaledRect    = AVMakeRect(aspectRatio: self.size, insideRect: maxRect)
            let scaledSize    = scaledRect.size
            return self.resize(to: scaledSize)
        }
        return self
    }
}
