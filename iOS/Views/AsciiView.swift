//
//  AsciiView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 6/30/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI
import UIKit

struct AsciiView: View {
    enum AlertType: Identifiable {
        case noAscii
        case shared
        case shareFailed
        
        var id: AlertType { self }
    }
    
    @Binding var image: UIImage?
    @State private var ascii: String?
    
    @State private var alert: AlertType? = nil
    @State private var showingShareActionSheet = false

    let asciiFont = UIFont(name: "Menlo", size: 7)!

    init(image: Binding<UIImage?>) {
        _image = image
        
        let appearance = UINavigationBar.appearance()
        
        // set colors
        appearance.barTintColor = UIColor(named: "NavBar")
        appearance.tintColor = .white
        
        // turn off the default behavior that messes up the colors
        appearance.isTranslucent = false
        appearance.shadowImage = nil
    }

    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)

            if let ascii = ascii {
                GeometryReader { proxy in
                    ZoomableText(text: ascii, frame: proxy.frame(in: .local))
                }
            } else {
                ProgressView("Converting")
            }
        }.onAppear {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                let asciiArt = AsciiArtist.createAsciiArt(image: image!, font: asciiFont)
                DispatchQueue.main.async {
                    ascii = asciiArt
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if ascii != nil {
                        showingShareActionSheet = true
                    } else {
                        alert = .noAscii
                    }
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }).actionSheet(isPresented: $showingShareActionSheet) {
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
            }
        }.alert(item: $alert) { alert in
            switch alert {
            case .noAscii:
                return Alert(
                    title: Text("Whoah There!"),
                    message: Text("You have to create some ascii art before you can share it.")
                )
            case .shared:
                return Alert(title: Text("Shared"), dismissButton: .default(Text("Yay!")))
            case .shareFailed:
                return Alert(
                    title: Text("Share Failed"),
                    message: Text("An error occurred.")
                )
            }
        }

    }

    func showShareSheet<Content>(content: Content) {
        let shareSheet = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { (_, completed, _, err) in
            if completed {
                if let err = err {
                    print("Share failed: \(err)")
                    alert = .shareFailed
                } else {
                    alert = .shared
                }
            }
        }
        UIApplication.shared.windows.first?.rootViewController?.present(shareSheet, animated: true, completion: nil)
    }
}

struct AsciiView_Previews: PreviewProvider {
    static var previews: some View {
        AsciiView(image: Binding.constant(UIImage(named: "example-image")!))
            .previewDevice("iPhone 11")
    }
}
