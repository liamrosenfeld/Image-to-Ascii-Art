//
//  NSOpenPanel+Image.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 1/3/21.
//  Copyright © 2021 Liam Rosenfeld. All rights reserved.
//

import AppKit

extension NSOpenPanel {
    static func selectImage() -> URL? {
        let selectPanel = NSOpenPanel()
        selectPanel.title = "Select an Image to Convert"
        selectPanel.showsResizeIndicator = true
        selectPanel.canChooseDirectories = false
        selectPanel.canChooseFiles = true
        selectPanel.allowsMultipleSelection = false
        selectPanel.canCreateDirectories = true
        selectPanel.allowedFileTypes = NSImage.imageTypes
        
        selectPanel.runModal()
        
        return selectPanel.url
    }
}
