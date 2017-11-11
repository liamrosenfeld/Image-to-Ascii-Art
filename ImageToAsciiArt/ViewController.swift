//
//  ViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit

class ViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, // required by image picker
    UIScrollViewDelegate
{
    fileprivate let labelFont = UIFont(name: "Menlo", size: 7)!
    fileprivate let maxImageSize = CGSize(width: 310, height: 310)
    fileprivate lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    fileprivate var currentLabel: UILabel?
    @IBOutlet weak var busyView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Setup
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // self.configureZoomSupport()
    }
    
    // Actions
    @IBAction func homePickImageTapped(_ sender: AnyObject) {
        print("WORKED")
        self.performSegue(withIdentifier: "homeToContent", sender: self)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.show(imagePicker, sender: self)
    }
    
    @IBAction func homeKermitTapped(_ sender: Any) {
        print("WORKED")
        self.performSegue(withIdentifier: "homeToContent", sender: self)
        print("WORKED2")
        displayImageNamed("kermit")

    }
    
    
    @IBAction func homeBatmanTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "homeToContent", sender: self)
        displayImageNamed("batman")
    }
    
    @IBAction func handleNewImageTapped(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.show(imagePicker, sender: self)
    }

    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            displayImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Rendering
    fileprivate func displayImageNamed(_ imageName: String)
    {
        displayImage(UIImage(named: imageName)!)
    }
    
    fileprivate func displayImage(_ image: UIImage)
    {
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
            }
            
            print(asciiArt)
            UIPasteboard.general.string = asciiArt

        }
    }
    
    fileprivate func displayAsciiArt(_ asciiArt: String)
    {
        let label = UILabel()
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
    
    // Zooming support
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
    
    // UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return currentLabel
    }
}
