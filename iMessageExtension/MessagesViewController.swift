//
//  MessagesViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/22/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, CompactDelegate, ExpandedDelegate {
    
    // MARK: - Setup
    let compactID:String = "compact"
    let expandedID:String = "expanded"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    override func didBecomeActive(with conversation: MSConversation) {
        presentVC(presentationStyle: self.presentationStyle)
    }
    
    func presentVC(presentationStyle:MSMessagesAppPresentationStyle) {
        let identifier = (presentationStyle == .compact) ? compactID : expandedID
        let controller = storyboard!.instantiateViewController(withIdentifier: identifier)
        
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
        
        if let compact = controller as? CompactViewController {
            compact.delegate = self
        }
        else if let expanded = controller as? ExpandedViewController {
            if (self.activeConversation?.selectedMessage?.url) != nil {
                // bring up content view
                let contentVC = ContentViewController()
                self.present(contentVC, animated: true, completion: nil)
            } else {
                expanded.delegate = self
            }
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
        presentVC(presentationStyle: presentationStyle)
    }
    
    func pickImage(){
        self.requestPresentationStyle(.expanded)
    }
        
    
    func sendMessage(art: String, image: UIImage) {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        message.layout = layout
        message.url = getMessageURL(art: "Ascii Art", image: image)
        self.activeConversation?.insert(message, completionHandler: { (err) in
            print("INSERT-ERROR \(err.debugDescription)")
        })
        self.dismiss()
    }
    
    func getMessageURL(art: String, image: UIImage) -> URL {
        var components = URLComponents()
        let qArt = URLQueryItem(name: "art", value: art)
        components.queryItems = [qArt]
        return components.url!
    }
}
