//
//  CompactViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/22/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit

protocol CompactDelegate {
    func pickImage()
}

class CompactViewController: UIViewController {
    
    //MARK: - Setup
    var delegate:CompactDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func pickImage(_ sender: Any) {
        delegate?.pickImage()
    }
    
}
