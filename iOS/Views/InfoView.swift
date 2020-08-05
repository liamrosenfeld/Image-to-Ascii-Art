//
//  InfoView.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/1/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                Spacer()
                Spacer()
                Spacer()
                
                VStack(alignment: .center) {
                    Text("This app is open source, so you can find the complete source code here:")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button("Source Code") {
                        UIApplication.shared.open(URL(string: "https://github.com/liamrosenfeld/Image-to-Ascii-Art")!)
                    }.buttonStyle(RoundStyle()).padding()
                    
                }.padding(20)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("If you have any issues to report or suggestions, submit them here:")
                    
                    Button("Issue Tracker") {
                        UIApplication.shared.open(URL(string: "https://github.com/liamrosenfeld/Image-to-Ascii-Art/issues")!)
                    }.buttonStyle(RoundStyle()).padding()
                    
                    Text("I use GitHub issues as my issue tracker, which requires a GitHub account to file an issue")
                        .font(.callout)
                }.foregroundColor(.white).multilineTextAlignment(.center).padding(20)
                
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("The font used to display the ASCII art is Menlo 7pt.")
                    Text("For best results, it should be used to display the ascii in external applications.")
                        
                }.foregroundColor(.white).multilineTextAlignment(.center).padding(20)

                Spacer()
                
                (Text(Image(systemName: "chevron.left.slash.chevron.right"))
                    + Text(" with ")
                    + Text(Image(systemName: "heart"))
                    + Text(" by Liam")
                )
                .accessibility(label: Text("Made with love by Liam"))
                .foregroundColor(.white)
                .padding()
            }
        }
    }
        
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoView()
                .previewDevice("iPhone 11")
            InfoView()
                .previewDevice("iPhone 8")
        }
    }
}
