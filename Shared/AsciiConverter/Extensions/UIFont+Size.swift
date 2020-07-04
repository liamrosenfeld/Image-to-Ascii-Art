//
//  UIFont+Size.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/3/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import UIKit

extension UIFont {
    func monoRatio() -> CGFloat {
        let attributes = [
            NSAttributedString.Key.font: self
        ]
        let size = "a".size(withAttributes: attributes)
        let ratio = size.width / size.height
        return ratio
    }
}
