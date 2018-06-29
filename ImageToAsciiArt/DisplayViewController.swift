//
//  DisplayViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/11/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit
import Firebase

class DisplayViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Setup
    fileprivate let labelFont = UIFont(name: "Menlo", size: 7)!
    fileprivate let maxImageSize = CGSize(width: 310, height: 310)
    fileprivate lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    fileprivate var currentLabel: UILabel?
    @IBOutlet weak var busyView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let ImagePickerController = UIImagePickerController()
    
    var asciiArt:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        triggerFromButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func backToHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleNewImageTapped(_ sender: UIButton) {
        pickImage()
    }
    
    @IBAction func share(_ sender: UIButton) {
        if self.asciiArt != nil {
            self.showShareMenu(sender)
        } else {
            alert(title: "Woah There!", message: "Please pick an image first", dismissText: "OK")
        }
    }
    
    // Save as Image
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
    
    // MARK: - Translates Home String Into an Action
    var whichButtonPressed: String?
    
    func triggerFromButton() {
        if whichButtonPressed! == "homePickImage" {
            pickImage()
            whichButtonPressed = "done"
        } else if whichButtonPressed! == "homeTakePicture" {
            takePicture()
            whichButtonPressed = "done"
        }
    }
    
    
    // MARK: - Image Picker
    func pickImage() {
        ImagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.show(ImagePickerController, sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            displayImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Camera
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ImagePickerController.delegate = self
            ImagePickerController.sourceType = .camera
            self.present(ImagePickerController, animated: true, completion: nil)
        } else {
            alert(title: "No Camera Available", message: nil, dismissText: "OK")
        }
    }
    
    // MARK: - Rendering
    fileprivate func displayImage(_ image: UIImage) {
        self.busyView.isHidden = false
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            let // Rotate first because the orientation is lost when resizing.
            rotatedImage = image.imageRotatedToPortraitOrientation(),
            resizedImage = rotatedImage.imageConstrainedToMaxSize(self.maxImageSize),
            asciiArtist  = AsciiArtist(resizedImage, self.palette),
            asciiArt     = asciiArtist.createAsciiArt()
            
            DispatchQueue.main.async {
                self.displayAsciiArt(asciiArt)
                self.busyView.isHidden = true
                self.scrollView.backgroundColor = UIColor.white
                Analytics.logEvent("convert", parameters: nil)
            }
            
            self.asciiArt = asciiArt
        }
    }
    
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
        
        self.asciiArt = asciiArt
    }
    
    // MARK: - Zooming support
    fileprivate func configureZoomSupport() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
    }
    
    fileprivate func updateZoomSettings(animated: Bool) {
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentLabel
    }
    
    // MARK: - UIAlertController
    func showShareMenu(_ sender: UIButton) {
        let shareMenu = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = self.asciiArt
            self.alert(title: "Copied!", message: nil, dismissText: "Yay!")
            Analytics.logEvent(AnalyticsEventShare, parameters: nil)
        }
        
        let image = UIAlertAction(title: "Image", style: .default) { action in
            UIImageWriteToSavedPhotosAlbum(self.convertToImage()!, nil, nil, nil)
            self.alert(title: "Saved!", message: nil, dismissText: "Yay!")
            Analytics.logEvent(AnalyticsEventShare, parameters: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        shareMenu.addAction(copy)
        shareMenu.addAction(image)
        shareMenu.addAction(cancel)
        
        if let popoverController = shareMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(shareMenu, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String?, dismissText: String) {
        let alert = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: dismissText, style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
