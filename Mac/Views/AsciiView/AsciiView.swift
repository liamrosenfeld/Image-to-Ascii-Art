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
    @State private var alert: AlertType? = nil
    
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
        .alert(item: $alert, content: matchAlert)
        .onAppear(perform: onAppear)
        .onChange(of: imageUrl, perform: generateAscii)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: newImage) {
                    Label("New Image", systemImage: "plus.square.on.square")
                }
            }
            ToolbarItem(placement: .automatic) {
                HStack {
                    Divider()
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: copyAsciiText) {
                    Label("Copy Text", systemImage: "doc.on.clipboard")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: saveFile) {
                    Label("Save File", systemImage: "doc")
                }
            }
        }
    }
    
    // MARK: - Alerts
    enum AlertType: Int8, Identifiable {
        case shared
        case shareFailed
        case prematureShare
        
        var id: Int8 { self.rawValue }
    }
    
    func matchAlert(alert: AlertType) -> Alert {
        switch alert {
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
        case .prematureShare:
            return Alert(
                title: Text("Whoah there!"),
                message: Text("You need to wait for the image to convert before sharing.")
            )
        }
    }
    
    // MARK: - Toolbar
    let fileSaver = FileSaver()
    
    func newImage() {
        guard let url = NSOpenPanel.selectImage() else { return }
        self.imageUrl = url
    }
    
    func copyAsciiText() {
        guard let asciiArt = ascii else {
            alert = .prematureShare
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(asciiArt, forType: .string)
        alert = .shared
    }
    
    func saveFile() {
        guard let ascii = ascii else {
            alert = .prematureShare
            return
        }
        
        do {
            let shared = try fileSaver.saveFile(ascii: ascii)
            if shared { alert = .shared }
        } catch {
            alert = .shareFailed
        }
    }
    
    
    // MARK: - Generating ASCII
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

struct AsciiView_Previews: PreviewProvider {
    
    static let url = Binding.constant(Bundle.main.url(forResource: "cowboy", withExtension: "png"))
    
    static var previews: some View {
        AsciiView(imageUrl: url)
    }
}
