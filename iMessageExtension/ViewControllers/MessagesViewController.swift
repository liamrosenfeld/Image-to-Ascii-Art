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

class MessagesViewController: MSMessagesAppViewController {

    // MARK: - Setup
    let compactID: String = "compact"
    let expandedID: String = "expanded"
    let contentID: String = "content"
    
    var ref: DatabaseReference!
    
    var artID: String?
    var asciiArt: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            ref = Database.database().reference()
        }
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
        
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        addChild(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParent: self)
        
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
        if presentationStyle == .compact {
            self.dismiss()
        } else {
            presentVC(presentationStyle: presentationStyle)
        }
    }
    
    // MARK: - Send ASCII Art to Content View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContent" {
            let url = String(describing: self.activeConversation!.selectedMessage!.url!)
            let destination = segue.destination as! ContentViewController
            let dataID = getQueryStringParameter(url: url, param: "artID")
            
            destination.delegate = self
            
            Database.database().reference().child("asciiArt").child(dataID!).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                self.asciiArt = snapshot.value as? String
                destination.asciiArt = self.asciiArt!
            })
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    // MARK: - Send Message + URL
    func sendMessage(art: String, image: UIImage) {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        message.layout = layout
        toFirebase(art: art)
        message.url = getMessageURL(artID: artID!)
        self.activeConversation?.insert(message, completionHandler: { (err) in
            print(err.debugDescription)
        })
        self.dismiss()
    }
    
    func toFirebase(art: String) {
        if ref == nil {
            ref = Database.database().reference()
        }
        let postArt = self.ref.child("asciiArt").childByAutoId()
        postArt.setValue(art)
        
        artID = postArt.key
    }
    
    func getMessageURL(artID: String) -> URL {
        var components = URLComponents()
        let qID = URLQueryItem(name: "artID", value: artID )
        components.queryItems = [qID]
        return components.url!
    }
}


// MARK: - Delegate Stuff
extension MessagesViewController: CompactDelegate, ExpandedDelegate, ContentDelegate {
    func pickImage() {
        self.requestPresentationStyle(.expanded)
    }
    
    func close() {
        self.dismiss()
    }
}
