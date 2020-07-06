//
//  CGImage+vImage.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/6/20.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import CoreGraphics
import Accelerate

extension CGImage {
    func toRGBBuffer() -> vImage_Buffer {
        // The format of the source asset.
        guard let sourceFormat = vImage_CGImageFormat(cgImage: self) else {
            fatalError("Unable to create format.")
        }
        
        // The buffer containing the source image.
        guard var sourceBuffer = try? vImage_Buffer(cgImage: self, format: sourceFormat)else {
            fatalError("Unable to create source buffer.")
        }
        
        // The 3-channel RGB format of the destination image.
        let rgbFormat = vImage_CGImageFormat.rgb
        
        
        // The buffer containing the image after gamma adjustment.
        guard var destinationBuffer = try? vImage_Buffer(
            width: Int(sourceBuffer.width),
            height: Int(sourceBuffer.height),
            bitsPerPixel: rgbFormat.bitsPerPixel
        ) else {
            fatalError("Unable to create destination buffer.")
        }
        
        // Populate the destination with only the color channels:
        vImageConvert_RGBA8888toRGB888(&sourceBuffer,
                                       &destinationBuffer,
                                       vImage_Flags(kvImageNoFlags))
        
        return destinationBuffer
    }
}

extension vImage_Buffer {
    func toImage() -> CGImage? {
        // Create a 3-channel `CGImage` instance from the interleaved buffer.
        return try? self.createCGImage(format: vImage_CGImageFormat.rgb)
    }
}

extension vImage_CGImageFormat {
    static let rgb = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8 * 3,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
        renderingIntent: .defaultIntent
    )!
}
