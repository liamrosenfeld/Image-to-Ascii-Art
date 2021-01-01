//
//  SysFont.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 1/1/21.
//  Copyright © 2021 liamrosenfeld. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
typealias SysFont  = UIFont
#elseif os(macOS)
import AppKit
typealias SysFont  = NSFont
#endif

extension SysFont {
    func monoRatio() -> CGFloat {
        let attributes = [
            NSAttributedString.Key.font: self
        ]
        let size = "a".size(withAttributes: attributes)
        let ratio = size.width / size.height
        return ratio
    }
}
