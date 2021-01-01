//
//  vImage+Gamma.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/5/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import Accelerate.vImage
import CoreGraphics

extension vImage_Buffer {
    /// note: breaks the alpha values
    func applyGamma(preset: ResponseCurvePreset) {
        // Create a planar representation of the interleaved destination buffer.
        // Because `destinationBuffer` is 4-channel, assign the planar destinationBuffer a width of 4x the interleaved width.
        var planarDestination = vImage_Buffer(
            data: self.data,
            height: self.height,
            width: self.width * 4,
            rowBytes: self.rowBytes
        )
        
        // Perform the adjustment.
        vImagePiecewiseGamma_Planar8(
            &planarDestination,
            &planarDestination,
            preset.exponentialCoefficients,
            preset.gamma,
            preset.linearCoefficients,
            preset.boundary,
            vImage_Flags(kvImageNoFlags)
        )
    }
}


// A structure that wraps piecewise gamma parameters.
struct ResponseCurvePreset {
    let boundary: Pixel_8
    let linearCoefficients: [Float]
    let exponentialCoefficients: [Float]
    let gamma: Float
    
    static let increaseContrast = ResponseCurvePreset(
        boundary: 255,
        linearCoefficients: [2, -0.5],
        exponentialCoefficients: [1, 0, 0],
        gamma: 0
    )
    
    static let increaseBrightness = ResponseCurvePreset(
        boundary: 0,
        linearCoefficients: [1, 0],
        exponentialCoefficients: [1, 0, 0],
        gamma: 1 / 3
    )
}
