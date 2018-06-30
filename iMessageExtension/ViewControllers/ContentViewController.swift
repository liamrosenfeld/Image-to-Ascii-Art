//
//  ContentViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/24/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit

protocol ContentDelegate {
    func close()
}

class ContentViewController: UIViewController {

    // MARK: - Setup
    var delegate: ContentDelegate!
    
    private let labelFont = UIFont(name: "Menlo", size: 7)!
    
    var currentLabel: UILabel?
    @IBOutlet weak var scrollView: UIScrollView!
    
    var asciiArt:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.asciiArt != nil {
            self.displayAsciiArt(asciiArt!)
        } else {
            serverErrorAlert()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func save(_ sender: Any) {
        showShareMenu()
    }
    
    // MARK: - UIAlertController
    func showShareMenu() {
        let share = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
        
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = self.asciiArt
            self.alert(title: "Copied!", message: nil, dismissText: "Yay!")
        }
        
        let image = UIAlertAction(title: "Image", style: .default) { action in
            UIImageWriteToSavedPhotosAlbum(self.convertToImage()!, nil, nil, nil)
            self.self.alert(title: "Saved!", message: nil, dismissText: "Yay!")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        share.addAction(copy)
        share.addAction(image)
        share.addAction(cancel)
        
        share.view.transform = CGAffineTransform(translationX: 0, y: -40) // Removes overlap with bottom bar
        
        present(share, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String?, dismissText: String) {
        let alert = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: dismissText, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func serverErrorAlert() {
        let imageAlert = UIAlertController(title: "ASCII Art Not Found", message:
            "Your ASCII Art Could Not Be Located On The Server", preferredStyle: UIAlertController.Style.alert)
        imageAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            self.delegate.close()
        }))
        
        self.present(imageAlert, animated: true, completion: nil)
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
    
    
    // MARK: - Display the Passed String
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
