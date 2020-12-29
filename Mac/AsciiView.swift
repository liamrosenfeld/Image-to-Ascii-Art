//
//  AsciiView.swift
//  Mac
//
//  Created by Liam Rosenfeld on 12/28/20.
//

import SwiftUI

struct AsciiView: View {
    @Binding var imageUrl: URL?
    
    var body: some View {
        Image(nsImage: NSImage(contentsOf: imageUrl!)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 350, maxWidth: 600, minHeight: 350, maxHeight: 600)
    }
}

struct AsciiView_Previews: PreviewProvider {
    
    static let url = Binding.constant(Bundle.main.url(forResource: "cowboy", withExtension: "png"))
    
    static var previews: some View {
        AsciiView(imageUrl: url)
    }
}
