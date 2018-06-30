//
//  DisplayViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/11/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit
import AsciiConverter
import Firebase
import MessageUI
import Messages

class DisplayViewController: UIViewController {

    // MARK: - Setup
    private let labelFont = UIFont(name: "Menlo", size: 7)!
    private let maxImageSize = CGSize(width: 310, height: 310)
    private lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    private var currentLabel: UILabel?
    @IBOutlet weak var busyView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let ImagePickerController = UIImagePickerController()
    
    var asciiArt:String?
    var picSelectMethod: String?
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if picSelectMethod! == "homePickImage" {
            pickImage()
            picSelectMethod = "done"
        } else if picSelectMethod! == "homeTakePicture" {
            takePicture()
            picSelectMethod = "done"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    @IBAction func backToHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newImage(_ sender: UIButton) {
        selectAnother()
    }
    
    @IBAction func share(_ sender: UIButton) {
        if self.asciiArt != nil {
            self.showShareMenu(sender)
        } else {
            alert(title: "Woah There!", message: "Please pick an image first", dismissText: "OK")
        }
    }
    
    // Save as Image
    func image(from view: UIScrollView) -> UIImage? {
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
    private func displayImage(_ image: UIImage) {
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

    
    // MARK: - UIAlertController
    func showShareMenu(_ sender: UIButton) {
        let shareMenu = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = self.asciiArt
            self.alert(title: "Copied!", message: nil, dismissText: "Yay!")
            Analytics.logEvent(AnalyticsEventShare, parameters: nil)
        }
        
        let image = UIAlertAction(title: "Image", style: .default) { action in
            UIImageWriteToSavedPhotosAlbum(self.image(from: self.scrollView)!, nil, nil, nil)
            self.alert(title: "Saved!", message: nil, dismissText: "Yay!")
            Analytics.logEvent(AnalyticsEventShare, parameters: nil)
        }
        
        let send = UIAlertAction(title: "iMessage", style: .default) { action in
            self.sendMessage(with: self.asciiArt!)
            Analytics.logEvent(AnalyticsEventShare, parameters: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        shareMenu.addAction(copy)
        shareMenu.addAction(image)
        if MFMessageComposeViewController.canSendText() {
            shareMenu.addAction(send)
        } else {
            print("SMS services are not available")
        }
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


// MARK: - Zooming support
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


// MARK: - Select Image
extension DisplayViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickImage() {
        ImagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.present(ImagePickerController, animated: true)
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
    
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ImagePickerController.delegate = self
            ImagePickerController.sourceType = .camera
            self.present(ImagePickerController, animated: true)
        } else {
            alert(title: "No Camera Available", message: nil, dismissText: "OK")
            print("Camera not avaliable :(")
        }
    }
    
    func selectAnother() {
        self.present(ImagePickerController, animated: true)
    }
}


// MARK: - Send iMessage
extension DisplayViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        if result == .sent {
            self.alert(title: "Sent!", message: nil, dismissText: "Yay!")
        }
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendMessage(with ascii: String) {
        setupFirebase()
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self as MFMessageComposeViewControllerDelegate
        
        // Create Message
        composeVC.message = MSMessage()
        composeVC.message?.layout = layout(image: image(from: scrollView)!)
        composeVC.message?.url = getURL(ascii: ascii)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func layout(image: UIImage) -> MSMessageLayout {
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        return layout
    }
    
    func setupFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            ref = Database.database().reference()
        }
    }
    
    func getURL(ascii: String) -> URL {
        // Send to Firebase
        if ref == nil {
            ref = Database.database().reference()
        }
        let postArt = self.ref.child("asciiArt").childByAutoId()
        postArt.setValue(ascii)
        let artID = postArt.key
        
        // Get Message URL
        var components = URLComponents()
        let qID = URLQueryItem(name: "artID", value: artID )
        components.queryItems = [qID]
        return components.url!
    }
}
