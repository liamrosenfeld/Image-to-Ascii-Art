//
//  AsciiPalette.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import Foundation
import Accelerate.vImage

/// Provides a list of ASCII symbols sorted from darkest to brightest.
class AsciiPalette {
 
    static func generate(for font: SysFont) -> [String] {
        // from ' ' to '~'
        return symbolsSortedByIntensityForAsciiCodes(32...126, font: font)
    }

    private static func symbolsSortedByIntensityForAsciiCodes(_ codes: CountableClosedRange<Int>, font: SysFont) -> [String] {
        let symbols          = codes.map { self.symbolFromAsciiCode($0) }
        let symbolImages     = symbols.map { $0.toImage(withFont: font) }
        let whitePixelCounts = symbolImages.map { self.countWhitePixelsInImage($0) }
        let sortedSymbols    = sortByIntensity(symbols, whitePixelCounts)
        return sortedSymbols
    }

    private static func symbolFromAsciiCode(_ code: Int) -> String {
        return String(Character(UnicodeScalar(code)!))
    }

    private static func countWhitePixelsInImage(_ image: SysImage) -> UInt {
        // Tet buffer from image
        let img = image.cgImage!
        var imgBuffer = try! vImage_Buffer(cgImage: img, format: .rgba)
        
        // Combine channels into blue channel
        let readableMatrix: [[Int16]] = [
            [3,     0,     0,    0],
            [0,     1,     1,    1],
            [0,     0,     0,    0],
            [0,     0,     0,    0]
        ]
        var matrix: [Int16] = [Int16](repeating: 0, count: 16)
        for i in 0...3 {
            for j in 0...3 {
                matrix[(3 - j) * 4 + (3 - i)] = readableMatrix[i][j]
            }
        }
        vImageMatrixMultiply_ARGB8888(&imgBuffer, &imgBuffer, matrix, 3, nil, nil, UInt32(kvImageNoFlags))
        
        // Take histogram
        // it is 8 bits per channel so the arrays are 256 long
        var alpha = [UInt](repeating: 0, count: 256)
        var red = [UInt](repeating: 0, count: 256)
        var green = [UInt](repeating: 0, count: 256)
        var blue = [UInt](repeating: 0, count: 256)
        
        let num = alpha.withUnsafeMutableBufferPointer { alphaPtr in
            red.withUnsafeMutableBufferPointer { redPtr in
                green.withUnsafeMutableBufferPointer { greenPtr in
                    blue.withUnsafeMutableBufferPointer { bluePtr -> UInt in
                        // calculate the histogram
                        var histogram = [redPtr.baseAddress, greenPtr.baseAddress, bluePtr.baseAddress, alphaPtr.baseAddress]
                        let error = vImageHistogramCalculation_ARGB8888(&imgBuffer, &histogram, UInt32(kvImageNoFlags))
                        guard error == kvImageNoError else {
                            fatalError("Error specifying histogram: \(error)")
                        }
                        
                        // the last item in the blue channel is the amount of white pixels
                        // because white is #fff
                        return bluePtr.last!
                    }
                }
            }
        }
        
        // Clean up and return
        imgBuffer.free()
        return num
    }

    private static func sortByIntensity(_ symbols: [String], _ whitePixelCounts: [UInt]) -> [String] {
        let mappings = Array(zip(whitePixelCounts, symbols))
        let unique   = mappings.removingDuplicates()
        let sorted   = unique.sorted { $0.0 < $1.0 } // the higher the lighter
        let sortedSymbols = sorted.map { $0.1 }

        return sortedSymbols
    }

}

extension Array where Element == (UInt, String) {
    func removingDuplicates() -> [Element] {
        var addedDict = [UInt: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0.0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
