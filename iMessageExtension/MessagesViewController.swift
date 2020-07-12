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

@objc(MessagesViewController)
class MessagesViewController: MSMessagesAppViewController {
    
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
    
    var artID: String? {
        let url = String(describing: self.activeConversation!.selectedMessage!.url!)
        guard let components = URLComponents(string: url) else { return nil }
        return components.queryItems?.first(where: { $0.name == "artID" })?.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
    
    var sub: AnyCancellable?
    var inputMode: InputMode = .none
    
    // MARK: - Conversation Handling
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        presentView(presentationStyle: presentationStyle)
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Keeps it from calling received controller twice
        if self.presentationStyle == .compact {
            presentView(presentationStyle: self.presentationStyle)
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
                print("send message")
            }
            setView(to: view)
        case .received:
            print("received view")
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
    
}
