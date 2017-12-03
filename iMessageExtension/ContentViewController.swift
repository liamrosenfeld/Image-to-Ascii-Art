//
//  ContentViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/24/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Setup
    fileprivate let labelFont = UIFont(name: "Menlo", size: 7)!
    
    fileprivate var currentLabel: UILabel?
    @IBOutlet weak var scrollView: UIScrollView!
    
    var asciiArt:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        displayAsciiArt(asciiArt!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func save(_ sender: Any) {
        showShareMenu()
    }

    // MARK: - Share Menu
    var asciiArtFinished:String?
    
    func showShareMenu() {
        let share = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = self.asciiArtFinished
            self.copiedAlert()
        }
        
        let image = UIAlertAction(title: "Image", style: .default) { action in
            UIImageWriteToSavedPhotosAlbum(self.convertToImage()!, nil, nil, nil)
            self.imageAlert()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        share.addAction(copy)
        share.addAction(image)
        share.addAction(cancel)
        
        share.view.transform = CGAffineTransform(translationX: 0, y: -40) // Removes overlap with bottom bar
        
        present(share, animated: true, completion: nil)
    }
    
    // For Image Option
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // Alerts
    func copiedAlert() {
        let copiedAlert = UIAlertController(title: "Copied!", message:
            nil, preferredStyle: UIAlertControllerStyle.alert)
        copiedAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(copiedAlert, animated: true, completion: nil)
    }
    
    func imageAlert() {
        let imageAlert = UIAlertController(title: "Saved!", message:
            nil, preferredStyle: UIAlertControllerStyle.alert)
        imageAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(imageAlert, animated: true, completion: nil)
    }
    
    // MARL: - Display the Passed String
    fileprivate func displayAsciiArt(_ asciiArt: String) {
        let
        label = UILabel()
        label.font = self.labelFont
        label.lineBreakMode = NSLineBreakMode.byClipping
        label.numberOfLines = 0
        label.text = asciiArt
        label.sizeToFit()
        
        currentLabel?.removeFromSuperview()
        currentLabel = label
        
        scrollView.addSubview(label)
        scrollView.contentSize = label.frame.size
        
        self.updateZoomSettings(animated: false)
        scrollView.contentOffset = CGPoint.zero
    }

    // MARK: - Zooming support
    fileprivate func configureZoomSupport()
    {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
    }
    
    fileprivate func updateZoomSettings(animated: Bool)
    {
        let
        scrollSize  = scrollView.frame.size,
        contentSize = scrollView.contentSize,
        scaleWidth  = scrollSize.width / contentSize.width,
        scaleHeight = scrollSize.height / contentSize.height,
        scale       = max(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return currentLabel
    }

}
