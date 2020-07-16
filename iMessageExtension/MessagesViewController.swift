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
            sub = delegate.sendMessage.sink { delegate in
                self.activeConversation?.insert(delegate.message) { (err) in
                    if let err = err {
                        print("Message insert error: \(err)")
                    } else {
                        self.dismiss()
                    }
                }
                
            }
            setView(to: view)
        case .received:
            let delegate = ReceivedDelegate()
            let message = self.activeConversation!.selectedMessage!
            let view = ReceivedView(message: message, delegate: delegate, parent: self)
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
