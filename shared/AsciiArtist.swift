//
//  AsciiArtist.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import Foundation
import UIKit

/** Transforms an image to ASCII art. */
class AsciiArtist {
    fileprivate let
    image:   UIImage,
    palette: AsciiPalette

    init(_ image: UIImage, _ palette: AsciiPalette) {
        self.image   = image
        self.palette = palette
    }

    func createAsciiArt() -> String {
        let
        dataProvider = image.cgImage?.dataProvider,
        pixelData    = dataProvider?.data,
        pixelPointer = CFDataGetBytePtr(pixelData),
        intensities  = intensityMatrixFromPixelPointer(pixelPointer!),
        symbolMatrix = symbolMatrixFromIntensityMatrix(intensities)
        return symbolMatrix.joined(separator: "\n")
    }
    
    fileprivate func intensityMatrixFromPixelPointer(_ pointer: PixelPointer) -> [[Double]] {
        let
        width  = Int(image.size.width),
        height = Int(image.size.height),
        matrix = Pixel.createPixelMatrix(width, height)
        return matrix.map { pixelRow in
            pixelRow.map { pixel in
                pixel.intensityFromPixelPointer(pointer)
            }
        }
    }
    
    fileprivate func symbolMatrixFromIntensityMatrix(_ matrix: [[Double]]) -> [String] {
        return matrix.map { intensityRow in
            intensityRow.reduce("") {
                $0 + self.symbolFromIntensity($1)
            }
        }
    }
    
    fileprivate func symbolFromIntensity(_ intensity: Double) -> String {
        assert(0.0 <= intensity && intensity <= 1.0)
        
        let
        factor = palette.symbols.count - 1,
        value  = round(intensity * Double(factor)),
        index  = Int(value)
        return palette.symbols[index]
    }
    
}
