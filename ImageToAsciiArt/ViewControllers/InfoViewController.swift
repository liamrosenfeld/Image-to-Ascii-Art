//
//  InfoViewController.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 12/14/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var gifView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        gifView.loadGif(name: "iMessageInstructions")
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
}
