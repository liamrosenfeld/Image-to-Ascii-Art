//
//  InfoView.swift
//  ImageToAsciiArt
//
//  Created by Liam Rosenfeld on 7/1/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI
import StoreKit

struct InfoView: View {
    
    @Binding var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        // Set Binding
        self._isPresented = isPresented
        
        // Set Appearance
        UITableView.appearance().backgroundColor = UIColor(Color.background)
        UINavigationBar.appearance().backgroundColor = UIColor(Color.background)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: footer) {
                    Button("View Source Code") {
                        UIApplication.shared.open(URL(string: "https://github.com/liamrosenfeld/Image-to-Ascii-Art")!)
                    }
                    Button("Submit Suggestions") {
                        UIApplication.shared.open(URL(string: "https://github.com/liamrosenfeld/Image-to-Ascii-Art/issues")!)
                    }
                    Button("Report Issue") {
                        UIApplication.shared.open(URL(string: "https://github.com/liamrosenfeld/Image-to-Ascii-Art/issues")!)
                    }
                    Button("Rate App") {
                        if let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Info")
            .navigationBarItems(leading: Button("Close", action: { isPresented = false }))
        }
    }
    
    var footer: some View = VStack(alignment: .leading, spacing: 8) {
        Text("Font used to display ASCII is Menlo 7pt")
            .font(.callout)
        (Text(Image(systemName: "chevron.left.slash.chevron.right"))
            + Text(" with ")
            + Text(Image(systemName: "heart"))
            + Text(" by Liam")
        )
            .accessibility(label: Text("Made with love by Liam"))
        .font(Font.body.bold())
    }.foregroundColor(.white)
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoView(Binding.constant(true))
                .previewDevice("iPhone 11")
            InfoView(Binding.constant(true))
                .previewDevice("iPhone 8")
        }
    }
}
