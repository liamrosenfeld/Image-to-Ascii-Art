//
//  String+UIImage.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/2/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func toImage(withFont font: UIFont) -> UIImage {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: font
        ]
        let textSize = self.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(textSize, true, 0)
        let context = UIGraphicsGetCurrentContext()!


        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: textSize))

        self.draw(at: CGPoint.zero, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
