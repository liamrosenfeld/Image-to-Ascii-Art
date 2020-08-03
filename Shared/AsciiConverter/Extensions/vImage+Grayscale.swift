//
//  vImage+Grayscale.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 8/1/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import Accelerate.vImage

extension vImage_Buffer {
    mutating func grayscale() -> vImage_Buffer {
        // Rec. 601 luma coefficients
        let alphaCoefficient: Float = 0
        let redCoefficient: Float   = 0.299
        let greenCoefficient: Float = 0.587
        let blueCoefficient: Float  = 0.114
        
        // Define the Coefficients Matrix
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)
        
        var coefficientsMatrix = [
            Int16(alphaCoefficient * fDivisor),
            Int16(redCoefficient   * fDivisor),
            Int16(greenCoefficient * fDivisor),
            Int16(blueCoefficient  * fDivisor)
        ]
        
        // Make destination buffer
        // Planar8 format so it has 1 byte per pixel
        var destinationBuffer = try! vImage_Buffer(size: size, bitsPerPixel: 8)
        
        // Perform the Matrix Multiply
        let preBias: [Int16] = [0, 0, 0, 0]
        let postBias: Int32 = 0
        
        vImageMatrixMultiply_ARGB8888ToPlanar8(
            &self,
            &destinationBuffer,
            &coefficientsMatrix,
            divisor,
            preBias,
            postBias,
            vImage_Flags(kvImageNoFlags)
        )
        
        
        return destinationBuffer
    }
}
