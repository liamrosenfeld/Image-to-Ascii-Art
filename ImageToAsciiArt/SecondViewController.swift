//
//  SecondViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/11/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit

class SecondViewController:
    UIViewController,
    UIScrollViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate // required by image picker
{
    // MARK: - Setup
    fileprivate let labelFont = UIFont(name: "Menlo", size: 7)!
    fileprivate let maxImageSize = CGSize(width: 310, height: 310)
    fileprivate lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    fileprivate var currentLabel: UILabel?
    @IBOutlet weak var busyView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleNewImageTapped(_ sender: UIButton) {
        pickImage()
    }
    
    // MARK: - Translates whichButtonPressed String Into an Action
    var whichButtonPressed: String?
    func triggerFromButton() {
        if whichButtonPressed! == "homePickImage" {
            pickImage()
            whichButtonPressed = "done"
        } else if whichButtonPressed! == "kermit" {
            displayImageNamed("kermit")
        } else if whichButtonPressed! == "batman" {
            displayImageNamed("batman")
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func pickImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.show(imagePicker, sender: self)
    }
    
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
