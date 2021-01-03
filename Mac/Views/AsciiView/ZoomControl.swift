//
//  ZoomControl.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 1/2/21.
//  Copyright © 2021 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

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
