//
//  CGSize+Util.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 3/27/21.
//

import AVFoundation

extension CGSize {
    func fitIn(_ constraint: CGSize) -> CGSize {
        // don't resize if already small enough
        let isTooBig =
            self.width  > constraint.width ||
            self.height > constraint.height
        if !isTooBig {
            return self
        }
        
        // resize
        let maxRect    = CGRect(origin: .zero, size: constraint)
        let scaledRect = AVMakeRect(aspectRatio: self, insideRect: maxRect)
        let scaledSize = scaledRect.size.rounded
        
        return scaledSize
    }
    
    var rounded: CGSize {
        return CGSize(width: self.width.rounded(), height: self.height.rounded())
    }
    
    var roundedUp: CGSize {
        CGSize(width: ceil(width), height: ceil(height))
    }
}
