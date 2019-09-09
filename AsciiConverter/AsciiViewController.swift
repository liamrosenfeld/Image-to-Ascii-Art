//
//  AsciiViewController.swift
//  AsciiConverter
//
//  Created by Liam on 6/30/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import UIKit

open class AsciiViewController: UIViewController {
    
    // MARK: - Setup
    public let labelFont = UIFont(name: "Menlo", size: 7)!
    public let maxImageSize = CGSize(width: 310, height: 310)
    open lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    open var currentLabel: UILabel?
    var asciiView: UIScrollView!
    
    open var asciiArt: String?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Save as Image
    open func image(from view: UIScrollView) -> UIImage? {
        UIGraphicsBeginImageContext(view.contentSize)
        
        let savedContentOffset = view.contentOffset
        let savedFrame = view.frame
        
        view.contentOffset = CGPoint.zero
        view.frame = CGRect(x: 0, y: 0, width: view.contentSize.width, height: view.contentSize.height)
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        view.contentOffset = savedContentOffset
        view.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    // MARK: - Rendering
    open func displayImage(_ image: UIImage, busyView: UIView) {
        busyView.isHidden = false
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            let // Rotate first because the orientation is lost when resizing.
            rotatedImage = image.imageRotatedToPortraitOrientation(),
            resizedImage = rotatedImage.imageConstrainedToMaxSize(self.maxImageSize),
            asciiArtist  = AsciiArtist(resizedImage, self.palette),
            asciiArt     = asciiArtist.createAsciiArt()
            
            DispatchQueue.main.async {
                self.displayAsciiArt(asciiArt)
                busyView.isHidden = true
                self.asciiView.backgroundColor = UIColor.white
            }
            
            self.asciiArt = asciiArt
        }
    }
    
    open func displayAsciiArt(_ asciiArt: String) {
        let
        label = UILabel()
        label.font = self.labelFont
        label.lineBreakMode = NSLineBreakMode.byClipping
        label.numberOfLines = 0
        label.text = asciiArt
        label.textColor = .black
        label.sizeToFit()
        
        currentLabel?.removeFromSuperview()
        currentLabel = label
        
        asciiView.addSubview(label)
        asciiView.contentSize = label.frame.size
        
        self.updateZoomSettings(animated: false)
        asciiView.contentOffset = CGPoint.zero
        
        self.asciiArt = asciiArt
    }
}


// MARK: - Zoom Support
extension AsciiViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentLabel
    }
    
    public func configureZoomSupport(for view: UIScrollView) {
        asciiView = view
        asciiView.delegate = self
        asciiView.maximumZoomScale = 5
    }
    
    public func updateZoomSettings(animated: Bool) {
        let
        scrollSize  = asciiView.frame.size,
        contentSize = asciiView.contentSize,
        scaleWidth  = scrollSize.width / contentSize.width,
        scaleHeight = scrollSize.height / contentSize.height,
        scale       = max(scaleWidth, scaleHeight)
        asciiView.minimumZoomScale = scale
        asciiView.setZoomScale(scale, animated: animated)
    }
}
