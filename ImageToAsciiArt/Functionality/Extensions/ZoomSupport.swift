//
//  ZoomSupport.swift
//  ImageToAsciiArt
//
//  Created by Liam on 6/30/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import UIKit

extension DisplayViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentLabel
    }
    
    func configureZoomSupport() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
    }
    
    func updateZoomSettings(animated: Bool) {
        let
        scrollSize  = scrollView.frame.size,
        contentSize = scrollView.contentSize,
        scaleWidth  = scrollSize.width / contentSize.width,
        scaleHeight = scrollSize.height / contentSize.height,
        scale       = max(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: animated)
    }
}
