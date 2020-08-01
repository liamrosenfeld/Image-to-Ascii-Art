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
        let preppedImage = prepImage(image: image, font: font) // RBGA UIImage -> Shrunk RBG CGImage
        let intensities  = getIntensities(of: preppedImage)
        let symbolMatrix = symbolMatrixFromIntensityMatrix(intensities, palette: palette)
        return symbolMatrix.joined(separator: "\n")
    }

    static private func prepImage(image: UIImage, font: UIFont) -> CGImage {
        // Put the image right way up
        let rotatedImage = image.fixedOrientation()
        
        // Get RGBA buffer for resizing operations
        // also normalizes image format to RGBA8888
        var rgbaBuffer = rotatedImage.cgImage!.toRGBABuffer()
        
        // Squash the image vertically so the added height of the non square characters doesn't stretch it vertically
        let squashRatio    = font.monoRatio()
        let squashedHeight = (rotatedImage.size.height * squashRatio).rounded()
        let squashedSize   = CGSize(width: rotatedImage.size.width, height: squashedHeight)
        var squashedBuffer = rgbaBuffer.resize(to: squashedSize)
        rgbaBuffer.free()

        // Constrain the image down
        let maxImageSize = CGSize(width: 310, height: 310)
        var constrainedBuffer = squashedBuffer.imageConstrained(to: maxImageSize, current: squashedSize)
        squashedBuffer.free()
        
        // Convert to RGB888 Buffer
        let rgbBuffer = constrainedBuffer.rgbaToRGB()
        constrainedBuffer.free()
        
        // Apply gamma function to make ascii art more defined
        rgbBuffer.applyGamma(preset: ResponseCurvePreset.increaseContrast)
        rgbBuffer.applyGamma(preset: ResponseCurvePreset.increaseBrightness)
        
        // Convert back to CGImage
        let editedImage = rgbBuffer.rgbToImage()!
        rgbBuffer.free()
        return editedImage
    }

    static private func getIntensities(of image: CGImage) -> [[Double]] {
        let dataProvider = image.dataProvider
        let pixelData    = dataProvider?.data
        let pixelPointer = CFDataGetBytePtr(pixelData)
        return intensityMatrixFromPixelPointer(pixelPointer!, w: image.width, h: image.height)
    }

    static private func intensityMatrixFromPixelPointer(_ pointer: PixelPointer, w width: Int, h height: Int) -> [[Double]] {
        let matrix = Pixel.createPixelMatrix(width, height)
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
