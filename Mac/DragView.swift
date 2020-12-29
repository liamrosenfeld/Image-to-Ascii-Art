//
//  DragView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 12/27/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct DragView: View {
    
    @Binding var imageUrl: URL?
    @State var isDropping = false
    
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300, minHeight: 60)
                .padding(.horizontal, 50)
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .padding(.vertical, 10)
            VStack {
                Spacer()
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, minHeight: 50)
                Text(isDropping ?  "That Would Work!": "Drag Image Here")
                Text("Or")
                    .padding(.top, 10)
                Button("Choose Image", action: selectImage)
                    
                Spacer()
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .onDrop(of: [.fileURL], delegate: self)
            .background(isDropping ? Color.gray.opacity(0.25) : Color.clear)
            .cornerRadius(18)
            
        }
        .padding(35)
        .frame(minWidth: 350, maxWidth: 600, minHeight: 350, maxHeight: 600)
    }
    
    func selectImage() {
        let selectPanel = NSOpenPanel()
        selectPanel.title = "Select an Image to Convert"
        selectPanel.showsResizeIndicator = true
        selectPanel.canChooseDirectories = false
        selectPanel.canChooseFiles = true
        selectPanel.allowsMultipleSelection = false
        selectPanel.canCreateDirectories = true
        selectPanel.allowedFileTypes = NSImage.imageTypes
        
        selectPanel.runModal()
        
        self.imageUrl = selectPanel.url
    }
}

extension DragView: DropDelegate {
    
    func validateDrop(info: DropInfo) -> Bool {
        // get provider
        let providers = info.itemProviders(for: [.fileURL])
        guard providers.count == 1 else { return false }
        guard let provider = providers.first else { return false }
        
        // create dispatch group
        var allowed = false
        let group = DispatchGroup()
        group.enter()
        
        // wait on provider to load and then get UTI
        provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { (urlData, error) in
            if let urlData = urlData {
                let url = URL(dataRepresentation: urlData, relativeTo: nil, isAbsolute: true)
                if let uti = (try? url?.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier {
                    allowed = NSImage.imageTypes.contains(uti)
                }
            }
            group.leave()
        }
        
        // return if is allowed
        group.wait()
        return allowed
    }
    
    func performDrop(info: DropInfo) -> Bool {
        // get provider
        let providers = info.itemProviders(for: [.fileURL])
        guard let provider = providers.first else { return false }
        
        // wait on provider to load and then get UTI
        provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { (urlData, error) in
            if let urlData = urlData {
                self.imageUrl = URL(dataRepresentation: urlData, relativeTo: nil, isAbsolute: true)
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        self.isDropping = true
    }
    
    func dropExited(info: DropInfo) {
        self.isDropping = false
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static private var imageUrl: URL?
    
    static var previews: some View {
        DragView(imageUrl: $imageUrl)
    }
}
