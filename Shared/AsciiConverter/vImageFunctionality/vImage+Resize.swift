//
//  vImage+Resize.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/31/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import Accelerate.vImage
import AVFoundation

extension vImage_Buffer {
    mutating func resize(to destSize: CGSize) -> vImage_Buffer {
        let format = vImage_CGImageFormat.rgba
        
        var destinationBuffer = try! vImage_Buffer(size: destSize, bitsPerPixel: format.bitsPerPixel)
        
        let error = vImageScale_ARGB8888(
            &self,
            &destinationBuffer,
            nil,
            vImage_Flags(kvImageHighQualityResampling)
        )
        guard error == kvImageNoError else { fatalError("\(error)") }
        
        return destinationBuffer
    }
    
    mutating func imageConstrained(to maxSize: CGSize, current: CGSize) -> vImage_Buffer {
        // don't resize if already small enough
        let isTooBig =
            self.width  > Int(maxSize.width) ||
            self.height > Int(maxSize.height)
        if !isTooBig {
            return self
        }
        
        // resize
        let maxRect    = CGRect(origin: CGPoint.zero, size: maxSize)
        let scaledRect = AVMakeRect(aspectRatio: self.size, insideRect: maxRect)
        let scaledSize = scaledRect.size.rounded
        return self.resize(to: scaledSize)
    }
}

extension CGSize {
    var rounded: CGSize {
        return CGSize(width: self.width.rounded(), height: self.height.rounded())
    }
    
    var roundedUp: CGSize {
        CGSize(width: ceil(width), height: ceil(height))
    }
}
