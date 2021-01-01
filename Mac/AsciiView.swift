//
//  AsciiView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 12/28/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

struct AsciiView: View {
    @Binding var imageUrl: URL?
    @State private var ascii: String?
    @State private var zoom: CGFloat = 0
    
    
    var body: some View {
        Group {
            if let ascii = ascii {
                ZStack(alignment: .top) {
                    GeometryReader { proxy in
                        ZoomableText(text: ascii, size: proxy.frame(in: .local).size, zoom: $zoom)
                    }
                    ZoomControl(zoom: $zoom)
                }
                
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                    Text("Converting...")
                    Spacer()
                }
            }
        }
        .onAppear(perform: onAppear)
        .onChange(of: imageUrl, perform: generateAscii)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    print("new image")
                }, label: {
                    Label("New Image", systemImage: "plus.square.on.square")
                })
            }
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    guard let asciiArt = ascii else { return }
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(asciiArt, forType: .string)
                }, label: {
                    Label("Copy Text", systemImage: "doc.on.clipboard")
                })
            }
        }
    }
    
    func onAppear() {
        if ascii == nil {
            generateAscii(imageURL: imageUrl)
        }
    }
    
    func generateAscii(imageURL: URL? ) {
        // Get Image
        guard let url = imageUrl else { return }
        let image = NSImage(contentsOf: url)
        
        // Reset view
        ascii = nil
        
        // Generate ascii
        DispatchQueue.global(qos: .userInitiated).async {
            let asciiArt = AsciiArtist.createAsciiArt(image: image!)
            DispatchQueue.main.async {
                ascii = asciiArt
            }
        }
    }
    
}

struct ZoomControl: View {
    
    @Binding var zoom: CGFloat
    @State private var hovering = false
    
    var body: some View {
        HStack {
            Image(systemName: "plus.magnifyingglass")
                .font(Font.title3.bold())
            
            if hovering {
                Slider(value: $zoom, in: 0...ZoomableText.maxZoom)
                    .frame(width: 150)
                    .transition(.scale)
            }
        }
        .frame(height: 25)
        .padding(8)
        .background(Color.gray)
        .cornerRadius(7)
        .padding()
        .onHover { isHovered in
            withAnimation {
                self.hovering = isHovered
            }
        }
    }
}

struct AsciiView_Previews: PreviewProvider {
    
    static let url = Binding.constant(Bundle.main.url(forResource: "cowboy", withExtension: "png"))
    
    static var previews: some View {
        AsciiView(imageUrl: url)
    }
}
