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
        let format = vImage_CGImageFormat.argb
        
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
}
