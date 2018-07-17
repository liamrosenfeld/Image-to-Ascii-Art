//
//  MessagesViewController.swift
//  iMessageExtension
//
//  Created by Liam Rosenfeld on 11/22/17.
//  Copyright © 2017 Liam Rosenfeld. All rights reserved.
//

import UIKit
import Messages
import Firebase

class MessagesViewController: MSMessagesAppViewController {

    // MARK: - Setup
    var artID: String?
    var picSelectMethod: String!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            ref = Database.database().reference()
        }
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            // TODO: Check Success
        }
    }

    
    // MARK: - Resizing
    override func didBecomeActive(with conversation: MSConversation) {
        // Keeps it from calling content controller twice
        if self.presentationStyle == .compact {
            presentVC(presentationStyle: self.presentationStyle)
        }
    }
    
    func presentVC(presentationStyle: MSMessagesAppPresentationStyle) {
        
        let identifier = getDesiredSizeID().rawValue
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
            expanded.delegate = self
            expanded.picSelectMethod = picSelectMethod
        }
        else if let content = controller as? ContentViewController {
            content.dataID = getDataID()
            content.delegate = self
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == .compact {
            self.dismiss()
        } else {
            presentVC(presentationStyle: presentationStyle)
        }
    }
    
    func getDesiredSizeID() -> sizeID {
        if presentationStyle == .compact {
            return .compactID
        } else {
            if self.activeConversation?.selectedMessage?.url != nil {
                return .contentID
            } else {
                return .expandedID
            }
        }
    }
    
    enum sizeID: String {
        case compactID = "compact"
        case expandedID = "expanded"
        case contentID = "content"
    }
    
    // MARK: - Get DataID For Content View
    func getDataID() -> String? {
        let url = String(describing: self.activeConversation!.selectedMessage!.url!)
        return getQueryStringParameter(url: url, param: "artID")
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


// MARK: - Manage Pres Style Requests
extension MessagesViewController: CompactDelegate, ExpandedDelegate, ContentDelegate {
    func selectImage(via method: String) {
        self.requestPresentationStyle(.expanded)
        picSelectMethod = method
    }
    
    func close() {
        self.dismiss()
    }
}
