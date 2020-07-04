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
                context!.interpolationQuality = CGInterpolationQuality.low
                context?.draw(cgImage!, in: targetRect)
                if let scaledCGImage = context?.makeImage() {
                    return UIImage(cgImage: scaledCGImage)
                }
            }
        }
        return self
    }

    func imageRotatedToPortraitOrientation() -> UIImage {
        let mustRotate = self.imageOrientation != .up
        if mustRotate {
            let rotatedSize = CGSize(width: size.height, height: size.width)
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext() {
                // Perform the rotation and scale transforms around the image's center.
                context.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)

                // Rotate the image upright.
                let
                degrees = self.degreesToRotate(),
                radians = degrees * .pi / 180.0
                context.rotate(by: CGFloat(radians))

                // Flip the image on the Y axis.
                context.scaleBy(x: 1.0, y: -1.0)

                let
                targetOrigin = CGPoint(x: -size.width/2, y: -size.height/2),
                targetRect   = CGRect(origin: targetOrigin, size: self.size)

                context.draw(self.cgImage!, in: targetRect)
                let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()

                return rotatedImage
            }
        }
        return self
    }

    private func degreesToRotate() -> Double {
        switch self.imageOrientation {
            case .right: return  90
            case .down:  return 180
            case .left:  return -90
            default:     return   0
        }
    }

}
