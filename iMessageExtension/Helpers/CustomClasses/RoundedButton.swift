//
//  RoundedButton.swift
//  ImageToAsciiArt
//
//  Created by Liam on 9/15/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    @IBInspectable var useCustomRadius: Bool = false
    
    @IBInspectable var customRadius: Int = 0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        if useCustomRadius {
            layer.cornerRadius = CGFloat(customRadius)
        } else {
            layer.cornerRadius = frame.size.height / 2
        }
        
    }
}
