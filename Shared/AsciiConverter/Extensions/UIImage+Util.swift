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
        let rect = CGRect(origin: .zero, size: destSize)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(destSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if isTooBig {
            let
            maxRect       = CGRect(origin: CGPoint.zero, size: maxSize),
            scaledRect    = AVMakeRect(aspectRatio: self.size, insideRect: maxRect),
            scaledSize    = scaledRect.size,
            targetRect    = CGRect(origin: CGPoint.zero, size: scaledSize),
            width         = Int(scaledSize.width),
            height        = Int(scaledSize.height),
            cgImage       = self.cgImage,
            bitsPerComp   = cgImage?.bitsPerComponent,
            compsPerPixel = 4, // RGBA
            bytesPerRow   = width * compsPerPixel,
            colorSpace    = cgImage?.colorSpace,
            bitmapInfo    = cgImage?.bitmapInfo,
            context       = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComp!,
                bytesPerRow: bytesPerRow,
                space: colorSpace!,
                bitmapInfo: (bitmapInfo?.rawValue)!
            )

            if context != nil {
                context?.draw(cgImage!, in: targetRect)
                if let scaledCGImage = context?.makeImage() {
                    return UIImage(cgImage: scaledCGImage)
                }
            }
        }
        return self
    }
}
