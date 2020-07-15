//
//  ReceivedView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/12/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI
import Combine
import UIKit
import CloudKit

class ReceivedDelegate {
    var makeNew = PassthroughSubject<Void, Never>()
}

struct ReceivedView: View {
    
    // Connection to the outside
    let dbID: String
    let delegate: ReceivedDelegate
    var parent: MessagesViewController
    
    // Internal ascii stuff
    private let database = CKContainer(identifier: "iCloud.com.liamrosenfeld.ImageToAsciiArt").publicCloudDatabase
    private let asciiFont = UIFont(name: "Menlo", size: 7)!
    @State private var ascii: String?
    
    // Showing UI State
    @State private var alert: AlertType? = nil
    @State private var showingShareActionSheet = false
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        delegate.makeNew.send()
                    }, label: {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .accessibility(value: Text("Reply with ASCII Art"))
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        if ascii != nil {
                            showingShareActionSheet = true
                        } else {
                            alert = .notDownloadedYet
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .accessibility(value: Text("Share"))
                    .padding(.trailing, 10)
                    .actionSheet(isPresented: $showingShareActionSheet) {
                        ActionSheet(title: Text("Share as"), buttons: [
                            .default(Text("Text")) {
                                showShareSheet(content: ascii)
                            },
                            .default(Text("Image")) {
                                showShareSheet(content: ascii!.toImage(withFont: asciiFont))
                            },
                            .cancel()
                        ])
                    }
                }.frame(minWidth: 0, maxWidth: .infinity).padding(10).background(Color.navBar)
                
                
                if let ascii = ascii {
                    GeometryReader { proxy in
                        ZoomableText(text: ascii, frame: proxy.frame(in: .local))
                    }
                } else {
                    VStack {
                        Spacer()
                        ProgressView("Downloading")
                        Spacer()
                    }
                }
            }
        }
        .alert(item: $alert, content: matchAlert)
        .onAppear(perform: fetchAscii)
    }
    
    enum AlertType: Identifiable {
        case downloadFailed
        case notDownloadedYet
        case shared
        case shareFailed
        
        var id: AlertType { self }
    }
    
    func matchAlert(alert: AlertType) -> Alert {
        switch alert {
        case .notDownloadedYet:
            return Alert(
                title: Text("Whoah There!"),
                message: Text("The ASCII Art must download before it can be shared.")
            )
        case .downloadFailed:
            return Alert(
                title: Text("ASCII Art Could Not Be Downloaded"),
                message: Text("Please check your internet connection.")
            )
        case .shared:
            return Alert(
                title: Text("Shared"),
                dismissButton: .default(Text("Yay!"))
            )
        case .shareFailed:
            return Alert(
                title: Text("Share Failed"),
                message: Text("An error occurred.")
            )
        }
    }
    
    func fetchAscii() {
        ascii = nil
        
        database.fetch(withRecordID: .init(recordName: dbID)) { (record, error) in
            if error != nil {
                DispatchQueue.main.async {
                    alert = .downloadFailed
                }
            } else {
                if let record = record {
                    if let fetchedAscii = record["text"] as? NSString {
                        DispatchQueue.main.async {
                            ascii = fetchedAscii as String
                        }
                    }
                }
            }
        }
    }
    
    func showShareSheet<Content>(content: Content) {
        let shareSheet = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { (_, completed, _, err) in
            if completed {
                if let err = err {
                    print("Share failed \(err)")
                    alert = .shareFailed
                } else {
                    alert = .shared
                }
            }
        }
        parent.present(shareSheet, animated: true, completion: nil)
    }
}
