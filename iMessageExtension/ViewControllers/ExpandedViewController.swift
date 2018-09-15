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

class ExpandedViewController: AsciiViewController {

    // MARK: - Setup
    var delegate:ExpandedDelegate?

    let ImagePickerController = UIImagePickerController()
    
    @IBOutlet open weak var busyView: UIView!
    @IBOutlet open weak var scrollView: UIScrollView!
    
    var picSelectMethod: PicMethod!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureZoomSupport(for: scrollView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if picSelectMethod == .pick {
            pickImage()
        } else if picSelectMethod == .take {
            takePicture()
        } else {
            // User Swiped Up Instead of Clicking Button
            pickImage()
        }
        
    }

    
    // MARK: - Actions
    @IBAction func sendMessage(_ sender: Any) {
        if  asciiArt != nil {
            let asciiArtImage:UIImage = self.image(from: scrollView)!
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
    
}

enum PicMethod {
    case pick
    case take
}
