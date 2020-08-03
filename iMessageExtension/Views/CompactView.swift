//
//  CompactView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/12/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

class CompactDelegate: ObservableObject {
    
    var modeSelected = PassthroughSubject<CompactDelegate, Never>()
    
    var mode: InputMode = .none {
        didSet {
            modeSelected.send(self)
        }
    }
}

enum InputMode {
    case none
    case pick
    case take
}

struct CompactView: View {
    
    @ObservedObject var delegate: CompactDelegate
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                Spacer()
                
                Logo()
                
                Spacer()
                
                HStack {
                    Spacer()
                    Spacer()
                    
                    Button(action: {
                        delegate.mode = .pick
                    }, label: {
                        Text(Image(systemName: "photo")) +
                        Text(" Pick Image")
                    })
                    .accessibility(label: Text("Pick Image"))
                    .buttonStyle(RoundStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        delegate.mode = .take
                    }, label: {
                        Text(Image(systemName: "camera")) +
                        Text(" Take Picture")
                    })
                    .accessibility(label: Text("Take Picture"))
                    .buttonStyle(RoundStyle())
                    
                    Spacer()
                    Spacer()
                }
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}

struct Logo: View {
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 0, maxHeight: 250)
                .padding(.top, 20)
        } else {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 15)
                .padding(.horizontal, 30)
        }
    }
}
