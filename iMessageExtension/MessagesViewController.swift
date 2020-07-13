//
//  MessagesViewController.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/12/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import Messages
import CloudKit

@objc(MessagesViewController)
class MessagesViewController: MSMessagesAppViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Keeps it from calling received controller twice
        if self.presentationStyle == .compact {
            presentView(presentationStyle: self.presentationStyle)
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        presentView(presentationStyle: presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        sub?.cancel()
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    // MARK: - Sending/Receiving Message
    
    let database = CKContainer(identifier: "iCloud.com.liamrosenfeld.ImageToAsciiArt").publicCloudDatabase
    
    var dbID: String? {
        let url = String(describing: self.activeConversation!.selectedMessage!.url!)
        guard let components = URLComponents(string: url) else { return nil }
        return components.queryItems?.first(where: { $0.name == "dbID" })?.value
    }
    
    let asciiFont = UIFont(name: "Menlo", size: 7)!
    
    func sendMessage(asciiArt: String) {
        // generate preview image
        let maxImageSize = CGSize(width: 500, height: 500)
        let image = asciiArt.toImage(withFont: asciiFont).imageConstrainedToMaxSize(maxImageSize)
        
        let message = makeMessage(asciiArt: asciiArt, image: image)
        
        saveToDatabase(asciiArt: asciiArt) { result in
            switch result {
            case .success(let id):
                message.url = self.makeMessageURL(dbID: id)
                
                self.activeConversation?.insert(message) { (err) in
                    print(err.debugDescription)
                }
                self.dismiss()
            case .failure(let err):
                // TODO: UI Feedback
                print("An error occurred with upload:")
                print(err.localizedDescription)
            }
            
        }
        
    }
    
    func saveToDatabase(asciiArt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let asciiRecord = CKRecord(recordType: "AsciiArt")
        asciiRecord["text"] = asciiArt as NSString
        
        database.save(asciiRecord) { (record, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let record = record {
                    completion(.success(record.recordID.recordName))
                }
            }
        }
        
    }
    
    func makeMessage(asciiArt: String, image: UIImage) -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "Ascii Art"
        message.layout = layout
        return message
    }
    
    func makeMessageURL(dbID: String) -> URL {
        var components = URLComponents()
        let qID = URLQueryItem(name: "dbID", value: dbID )
        components.queryItems = [qID]
        return components.url!
    }
    
    // MARK: - Displaying
    
    var sub: AnyCancellable?
    var inputMode: InputMode = .none
    
    enum Mode {
        case compact
        case send
        case received
    }
    
    var activeMode: Mode {
        if presentationStyle == .compact {
            return .compact
        } else {
            if self.activeConversation?.selectedMessage?.url != nil {
                return .received
            } else {
                return .send
            }
        }
    }
    
    func presentView(presentationStyle: MSMessagesAppPresentationStyle) {
        sub?.cancel()
        
        switch activeMode {
        case .compact:
            let delegate = CompactDelegate()
            let view = CompactView(delegate: delegate)
            sub = delegate.modeSelected.sink { delegate in
                self.requestPresentationStyle(.expanded)
                self.inputMode = delegate.mode
            }
            setView(to: view)
        case .send:
            let delegate = SendDelegate()
            let view = SendView(mode: inputMode, delegate: delegate)
            sub = delegate.sendAscii.sink { delegate in
                self.sendMessage(asciiArt: delegate.asciiToSend)
            }
            setView(to: view)
        case .received:
            guard let dbID = dbID else {
                preconditionFailure("dbID is not present in the message")
            }
            let delegate = ReceivedDelegate()
            let view = ReceivedView(dbID: dbID, delegate: delegate, parent: self)
            sub = delegate.makeNew.sink { _ in
                self.activeConversation?.selectedMessage?.url = nil // get out of current message so it doesn't pop back up
                self.requestPresentationStyle(.compact)
            }
            setView(to: view)
        }
    }
    
    func setView<T: View>(to view: T) {
        // remove all existing views from parent
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        let vc  = UIHostingController(rootView: view)
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        vc.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
