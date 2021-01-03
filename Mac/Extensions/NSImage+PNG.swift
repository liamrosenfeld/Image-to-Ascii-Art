//
//  NSImage+PNG.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 1/3/21.
//  Copyright © 2021 Liam Rosenfeld. All rights reserved.
//

import AppKit

extension NSImage {
    var PNGRepresentation: Data? {
        guard let tiff = self.tiffRepresentation else { return nil }
        guard let tiffData = NSBitmapImageRep(data: tiff) else { return nil }
        return tiffData.representation(using: .png, properties: [:])
    }
    
    func savePng(to url: URL) throws {
        guard let png = self.PNGRepresentation else {
            throw NSImageError.getDataFailed
        }
        try png.write(to: url, options: .atomicWrite)
    }
    
    enum NSImageError: Error {
        case getDataFailed
    }
}
