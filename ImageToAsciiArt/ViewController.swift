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
    UINavigationControllerDelegate // required by image picker
{
    fileprivate let labelFont = UIFont(name: "Menlo", size: 7)!
    fileprivate let maxImageSize = CGSize(width: 310, height: 310)
    fileprivate lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    // Setup
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // Actions
    @IBAction func homePickImage(_ sender: Any) {
        self.performSegue(withIdentifier: "homeToContent", sender: self)
        //let imagePicker = UIImagePickerController()
        //imagePicker.delegate = self
        //self.show(imagePicker, sender: self)
    }
    
    @IBAction func kermit(_ sender: Any) {
        self.performSegue(withIdentifier: "homeToContent", sender: self)
        //displayImageNamed("kermit")
    }

    @IBAction func batman(_ sender: Any) {
        self.performSegue(withIdentifier: "homeToContent", sender: self)
        //displayImageNamed("batman")
    }    

    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            //displayImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
