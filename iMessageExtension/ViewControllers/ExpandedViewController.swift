//
//  ExpandedViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/22/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit
import AsciiConverter

protocol ExpandedDelegate {
    func sendMessage(art:String, image:UIImage)
}

class ExpandedViewController: UIViewController {

    // MARK: - Setup
    var delegate:ExpandedDelegate?
    
    private let labelFont = UIFont(name: "Menlo", size: 7)!
    private let maxImageSize = CGSize(width: 310, height: 310)
    private lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)

    var currentLabel: UILabel?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var busyView: UIView!

    let ImagePickerController = UIImagePickerController()
    
    var asciiArt:String?
    var picSelectMethod: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if picSelectMethod == "pick" {
            pickImage()
        } else if picSelectMethod == "take" {
            takePicture()
        } else {
            // User Swiped Up Instead of Clicking Button
            pickImage()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    @IBAction func sendMessage(_ sender: Any) {
        if  asciiArt != nil {
            let asciiArtImage:UIImage = self.convertToImage()!
            delegate?.sendMessage(art: asciiArt!, image: asciiArtImage)
        } else {
            alert(title: "Woah there!", message: "Please pick an image first", dismissText: "Ok")
        }
    }

    @IBAction func newImage(_ sender: Any) {
        selectAnother()
    }

    // MARK: - Alert
    func alert(title: String, message: String?, dismissText: String) {
        let alert = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: dismissText, style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Image Converter
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

    
    // MARK: - Rendering
    func displayImage(_ image: UIImage) {
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
            }
            
            self.asciiArt = asciiArt
        }
    }
    
    private func displayAsciiArt(_ asciiArt: String) {
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
}
