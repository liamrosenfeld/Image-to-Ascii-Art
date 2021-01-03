//
//  FileSaver.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 1/2/21.
//  Copyright © 2021 Liam Rosenfeld. All rights reserved.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers.UTType

struct FileSaver {
    let savePanel = NSSavePanel()
    
    func saveFile(ascii: String) throws -> Bool {
        // create panel
        savePanel.title = "Save Your ASCII Art"
        savePanel.allowedContentTypes = [.png]
        savePanel.isExtensionHidden = false
        
        // add filetype selector
        let accessoryView = NSHostingView(rootView: FileTypeSelector(panel: savePanel))
        savePanel.accessoryView = accessoryView
        
        // get url to save to
        let response = savePanel.runModal()
        guard response == .OK else { return false }
        guard let url = savePanel.url else { return false }
        
        // save file
        let type = savePanel.allowedContentTypes[0]
        switch type {
        case .png:
            try ascii.toImage(withFont: AsciiArtist.font).savePng(to: url)
        case .plainText:
            try ascii.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        default:
            fatalError("unimplemented file format")
        }
        
        return true
    }
    
    struct FileType: Identifiable, Hashable {
        let name: String
        let type: UTType
        
        var id: String {
            type.identifier
        }
    }
    
    struct FileTypeSelector: View {
        let options: [FileType] = [
            FileType(name: "png", type: .png),
            FileType(name: "txt", type: .plainText)
        ]
        
        @State private var selected = FileType(name: "png", type: .png)
        
        let panel: NSSavePanel
        
        var body: some View {
            Picker("File Format: ", selection: $selected) {
                ForEach(options) { option in
                    Text(option.name).tag(option)
                }
            }
            .frame(maxWidth: 300)
            .padding()
            .onChange(of: selected) { value in
                panel.allowedContentTypes = [value.type]
            }
        }
    }
}

extension NSImage {
    var PNGRepresentation: Data? {
        guard let tiff = self.tiffRepresentation else { return nil }
        guard let tiffData = NSBitmapImageRep(data: tiff) else { return nil }
        return tiffData.representation(using: .png, properties: [:])
    }
    
    func savePng(to url: URL) throws {
        guard let png = self.PNGRepresentation else {
            throw NSImageError.getDataFailed
        }
        try png.write(to: url, options: .atomicWrite)
    }
    
    enum NSImageError: Error {
        case getDataFailed
    }
}
