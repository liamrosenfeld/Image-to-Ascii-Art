//
//  MacApp.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 12/27/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

@main
struct MacApp: App {
    @State private var imageURL: URL?
    
    var body: some Scene {
        WindowGroup {
            if imageURL != nil {
                AsciiView(imageUrl: $imageURL)
                    .frame(minWidth: 550, minHeight: 500)
            } else {
                DragView(imageUrl: $imageURL)
                    .frame(minWidth: 350, minHeight: 350)
            }
        }
    }
}
