//
//  AsciiArtist.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import Foundation
import UIKit

// Transforms an image to ASCII art.
struct AsciiArtist {
    
    static func createAsciiArt(image: UIImage, font: UIFont) -> String {
        let palette      = AsciiPalette(font: font)
        let preppedImage = prepImage(image: image, font: font)
        let intensities  = getIntensities(of: preppedImage)
        let symbolMatrix = symbolMatrixFromIntensityMatrix(intensities, palette: palette)
        return symbolMatrix.joined(separator: "\n")
    }
    
    static private func prepImage(image: UIImage, font: UIFont) -> UIImage {
        // Squash the image vertically so the added height of the non square characters doesn't stretch it vertically
        let squashRatio    = font.monoRatio()
        let squashedHeight = image.size.height * squashRatio
        let squashedSize   = CGSize(width: image.size.width, height: squashedHeight)
        let squashedImage  = image.resize(to: squashedSize)
        
        // constrain the image down
        let maxImageSize = CGSize(width: 310, height: 310)
        let constrainedImage = squashedImage.imageConstrainedToMaxSize(maxImageSize)
        
        return constrainedImage
    }
    
    static private func getIntensities(of image: UIImage) -> [[Double]] {
        let dataProvider = image.cgImage?.dataProvider
        let pixelData    = dataProvider?.data
        let pixelPointer = CFDataGetBytePtr(pixelData)
        return intensityMatrixFromPixelPointer(pixelPointer!, imgSize: image.size)
    }
    
    static private func intensityMatrixFromPixelPointer(_ pointer: PixelPointer, imgSize: CGSize) -> [[Double]] {
        let matrix = Pixel.createPixelMatrix(Int(imgSize.width), Int(imgSize.height))
        return matrix.map { pixelRow in
            pixelRow.map { pixel in
                pixel.intensityFromPixelPointer(pointer)
            }
        }
    }
    
    static private func symbolMatrixFromIntensityMatrix(_ matrix: [[Double]], palette: AsciiPalette) -> [String] {
        return matrix.map { intensityRow in
            intensityRow.reduce("") {
                $0 + self.symbolFromIntensity($1, palette: palette)
            }
        }
    }
    
    static private func symbolFromIntensity(_ intensity: Double, palette: AsciiPalette) -> String {
        assert(0.0 <= intensity && intensity <= 1.0)
        
        let factor = palette.symbols.count - 1
        let value  = round(intensity * Double(factor))
        let index  = Int(value)
        return palette.symbols[index]
    }
    
}
