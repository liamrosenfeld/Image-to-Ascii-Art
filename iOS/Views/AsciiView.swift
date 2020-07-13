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
    @Binding var image: UIImage?
    @State private var ascii: String?
    @State private var showingShareActionSheet = false
    @State private var showingNoAsciiAlert = false

    let asciiFont = UIFont(name: "Menlo", size: 7)!

    init(image: Binding<UIImage?>) {
        _image = image

        UINavigationBar.appearance().barTintColor = UIColor(named: "DarkBlue")
        UINavigationBar.appearance().tintColor = .white
    }

    var body: some View {
        ZStack {
            Color("DarkBlue")
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
                        showingNoAsciiAlert = true
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
                }.alert(isPresented: $showingNoAsciiAlert) {
                    Alert(title: Text("Whoah There!"), message: Text("You have to create some ascii art before you can share it."))
                }
            }
        }
    }

    func showShareSheet<Content>(content: Content) {
        let shareSheet = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(shareSheet, animated: true, completion: nil)
    }
}

struct AsciiView_Previews: PreviewProvider {
    static var previews: some View {
        AsciiView(image: Binding.constant(UIImage(named: "example-image")!))
            .previewDevice("iPhone 11")
    }
}
