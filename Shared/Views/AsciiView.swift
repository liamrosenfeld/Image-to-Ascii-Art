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
    
    let labelFont = UIFont(name: "Menlo", size: 7)!
    let maxImageSize = CGSize(width: 310, height: 310)
    
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
            let palette = AsciiPalette(font: self.labelFont)
    
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                // Rotate first because the orientation is lost when resizing.
                let rotatedImage = image!.imageRotatedToPortraitOrientation()
                let resizedImage = rotatedImage.imageConstrainedToMaxSize(maxImageSize)
                let asciiArtist  = AsciiArtist(resizedImage, palette)
                let asciiArt     = asciiArtist.createAsciiArt()
    
                DispatchQueue.main.async {
                    ascii = asciiArt
                }
            }
        }.navigationBarTitle("", displayMode: .inline)
    }
}

struct AsciiView_Previews: PreviewProvider {
    static var previews: some View {
        AsciiView(image: Binding.constant(UIImage(named: "example-image")!))
            .previewDevice("iPhone 11")
    }
}
 


