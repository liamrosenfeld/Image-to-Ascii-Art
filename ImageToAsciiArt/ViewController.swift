//
//  ViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 11/1/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Setup
    var buttonPressed: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToContent" {
            let destination = segue.destination as! SecondViewController
            destination.whichButtonPressed = buttonPressed!
        }
    }
    
    // MARK: - Actions
    @IBAction func homePickImage(_ sender: Any) {
        buttonPressed = "homePickImage"
        self.performSegue(withIdentifier: "homeToContent", sender: self)
    }
    
    @IBAction func kermit(_ sender: Any) {
        buttonPressed = "kermit"
        self.performSegue(withIdentifier: "homeToContent", sender: self)
    }

    @IBAction func batman(_ sender: Any) {
        buttonPressed = "batman"
        self.performSegue(withIdentifier: "homeToContent", sender: self)
    }
    
}
