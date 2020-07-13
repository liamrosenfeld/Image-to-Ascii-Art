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
                
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.all, 10)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    GetImageButton(set: $delegate.mode, setTo: .pick)
                    
                    Spacer()
                    
                    GetImageButton(set: $delegate.mode, setTo: .take)
                    
                    Spacer()
                }
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}

struct GetImageButton: View {
    @Binding var set: InputMode
    let setTo: InputMode
    
    var body: some View {
        Button(action: {
            set = setTo
        }, label: {
            HStack {
                Image(systemName: setTo == InputMode.take ? "camera" : "photo")
                Text(setTo == InputMode.take ? "Take Picture" : "Pick Image")
            }
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.button)
            .cornerRadius(10)
        })
    }
}
