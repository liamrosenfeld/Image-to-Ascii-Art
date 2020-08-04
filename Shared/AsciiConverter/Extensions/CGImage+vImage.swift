//
//  CGImage+vImage.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/6/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import Accelerate.vImage
import CoreGraphics

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
        
        // Free source buffer and return dest buffer
        sourceBuffer.free()
        return destBuffer
    }
}

extension vImage_Buffer {
    func toImage(format: vImage_CGImageFormat) -> CGImage {
        return try! self.createCGImage(format: format)
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
    
    static let planar = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8,
        colorSpace: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
        renderingIntent: .defaultIntent
    )!
}
