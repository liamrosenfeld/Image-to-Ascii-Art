//
//  MessagesViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/22/17.
//  Copyright © 2017 liamrosenfeld. All rights reserved.
//

import UIKit
import Messages
import Firebase

class MessagesViewController: MSMessagesAppViewController, CompactDelegate, ExpandedDelegate {
    
    // MARK: - Setup
    let compactID:String = "compact"
    let expandedID:String = "expanded"
    
    var ref: DatabaseReference!
    
    var dataID:String? = "KEEP THIS TEXT HERE UNTIL YOU FIGURE OUT ID SAVING"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        ref = Database.database().reference()
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
                self.performSegue(withIdentifier: "toContent", sender: self)
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
    
    func pickImage() {
        self.requestPresentationStyle(.expanded)
    }
    
    // MARK: - Send ASCII Art to Content View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContent" {
            let url = String(describing: self.activeConversation!.selectedMessage!.url)
            let destination = segue.destination as! ContentViewController
            var dataID = getQueryStringParameter(url: url, param: "databaseID")
            
            // TODO - Get string from firebase
            // TODO - Send string to "destination.asciiArt"
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    // TODO - Function to get string from firbase
    
    // MARK: - Send Message + URL
    func sendMessage(art: String, image: UIImage) {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        message.layout = layout
        toFirebase(art: art)
        message.url = getMessageURL(databaseID: dataID!)
        self.activeConversation?.insert(message, completionHandler: { (err) in
            print("INSERT-ERROR \(err.debugDescription)")
        })
        self.dismiss()
    }
    
    func toFirebase(art: String) {
        self.ref.child("asciiArt").setValue(art)
        // TODO - GET ID
    }
    
    func getMessageURL(databaseID: String) -> URL {
        var components = URLComponents()
        let qID = URLQueryItem(name: "databaseID", value: databaseID)
        components.queryItems = [qID]
        return components.url!
    }
}
