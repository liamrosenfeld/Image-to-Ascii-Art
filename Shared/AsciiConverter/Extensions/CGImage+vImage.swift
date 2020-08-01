//
//  CGImage+vImage.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/6/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import CoreGraphics
import Accelerate

extension CGImage {
    func toRGBABuffer() -> vImage_Buffer {
        // The format of the source asset
        guard var sourceFormat = vImage_CGImageFormat(cgImage: self) else {
            fatalError("Unable to create format.")
        }
        
        // The desired format
        var destFormat = vImage_CGImageFormat.rgba
        
        // Don't do anything if it's already in the desired format
        // TODO: make it actually work because bitmapInfo messes it up
        if vImageCGImageFormat_IsEqual(&sourceFormat, &destFormat) {
            return try! vImage_Buffer(cgImage: self, format: sourceFormat)
        }
        
        // Make a converter between the two formats
        let converter = try! vImageConverter.make(
            sourceFormat: sourceFormat,
            destinationFormat: destFormat
        )
        
        // Verify the number of source and destination buffers.
        assert(vImageConverter_GetNumberOfSourceBuffers(converter) == 1,
               "Number of source buffers should be 1.")
        assert(vImageConverter_GetNumberOfDestinationBuffers(converter) == 1,
               "Number of destination buffers should be 1.")
        
        // Create, initialize, and fill the source buffer
        let sourceBuffer = try! vImage_Buffer(cgImage: self, format: sourceFormat)
        
        // Create and initialize the destination buffer
        var destBuffer = try! vImage_Buffer(size: sourceBuffer.size, bitsPerPixel: destFormat.bitsPerPixel)
        
        // Convert into destination buffer
        try! converter.convert(source: sourceBuffer, destination: &destBuffer)
    
        return destBuffer
    }
}

extension vImage_Buffer {
    func rgbToImage() -> CGImage? {
        // Create a 3-channel `CGImage` instance from the interleaved buffer.
        return try? self.createCGImage(format: vImage_CGImageFormat.rgb)
    }
    
    func rgbaToImage() -> CGImage? {
        // Create 4-channel `CGImage` instance from the interleaved buffer.
        return try? self.createCGImage(format: vImage_CGImageFormat.rgba)
    }
    
    mutating func rgbaToRGB() -> vImage_Buffer {
        guard var destinationBuffer = try? vImage_Buffer(
            size: self.size,
            bitsPerPixel: vImage_CGImageFormat.rgb.bitsPerPixel
        ) else {
            fatalError("Unable to create destination buffer.")
        }
        
        vImageConvert_RGBA8888toRGB888(&self, &destinationBuffer, vImage_Flags(kvImageNoFlags))
        return destinationBuffer
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
    
    static let rgba = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8 * 4,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
        renderingIntent: .defaultIntent
    )!
}
