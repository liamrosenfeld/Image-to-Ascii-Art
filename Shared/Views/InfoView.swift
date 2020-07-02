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
            Color("DarkBlue")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "chevron.left.slash.chevron.right")
                    Text("with")
                    Image(systemName: "heart")
                    Text("by Liam")
                }.foregroundColor(.white).padding()
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
