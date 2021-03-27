//
//  AsciiArtist.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import Foundation
import Accelerate.vImage

/// Transforms an image to ASCII art.
struct AsciiArtist {
    
    #if os(iOS)
    static let font = SysFont(name: "Menlo", size: 7)!
    #elseif os(macOS)
    static let font = SysFont(name: "Menlo", size: 20)!
    #endif
    static let palette = AsciiPalette.generate(for: AsciiArtist.font)

    static func createAsciiArt(image: SysImage) -> String {
        var origBuffer      = image.makeBuffer()
        var resizedBuffer   = resize(buffer: &origBuffer)
        let grayscaleBuffer = convertToGrayscale(buffer: &resizedBuffer)
        let asciiArt  = grayscaleToSymbols(buffer: grayscaleBuffer)
        return asciiArt
    }

    static private func resize(buffer: inout vImage_Buffer) -> vImage_Buffer {
        // Squash the size vertically
        // So the added height of the non square characters doesn't stretch it vertically
        let squashRatio    = font.monoRatio()
        let squashedHeight = (buffer.size.height * squashRatio).rounded()
        let squashedSize   = CGSize(width: buffer.size.width, height: squashedHeight)
        
        // Constrain the image down
        // So the conversion doesn't take too long
        // Also makes the ascii more visible
        let maxImageSize = CGSize(width: 310, height: 310)
        let constrainedSize = squashedSize.fitIn(maxImageSize)

        // Resize image
        let resizedBuffer = buffer.resize(to: constrainedSize)
        
        // Free input buffer and return
        buffer.free()
        return resizedBuffer
    }
    
    static private func convertToGrayscale(buffer: inout vImage_Buffer) -> vImage_Buffer {
        // Apply gamma functions to make ascii art more defined
        // breaks the alpha values
        buffer.applyGamma(preset: .increaseContrast)
        buffer.applyGamma(preset: .increaseBrightness)
        
        // Convert image to grayscale
        // ignores alpha channel
        let grayscaleBuffer = buffer.grayscale()
        
        // Free buffer and return
        buffer.free()
        return grayscaleBuffer
    }
    
    static private func grayscaleToSymbols(buffer: vImage_Buffer) -> String {
        // Int width instead of UInt
        let width = Int(buffer.width)
        let height = Int(buffer.height)
        
        // Reserve string capacity ahead of time for performance
        let strLength = height * (width + 1) // the +1 is for the \n at the end of each line
        var ascii = String()
        ascii.reserveCapacity(strLength)
        
        // Get Data Buffer from vImage Buffer
        let dataLength = height * buffer.rowBytes
        let dataPtr = buffer.data.bindMemory(to: UInt8.self, capacity: dataLength)
        let dataBuffer = UnsafeBufferPointer(start: dataPtr, count: dataLength)
        
        // Iterate over data and convert
        for row in 0..<height {
            let rowStart = row * buffer.rowBytes
            for col in 0..<width {
                let intensity = dataBuffer[rowStart + col]
                let symbol = symbolFromIntensity(intensity)
                ascii.append(symbol)
            }
            ascii.append("\n")
        }
        ascii.remove(at: ascii.index(before: ascii.endIndex)) // remove last \n
        
        // Free buffer and return
        buffer.free()
        return ascii
    }
    
    static private func symbolFromIntensity(_ intensity: UInt8) -> String {
        assert(0 <= intensity && intensity <= 255)

        let factor = palette.count - 1
        let value  = round((Double(intensity) / 255) * Double(factor))
        let index  = Int(value)
        return palette[index]
    }

}
