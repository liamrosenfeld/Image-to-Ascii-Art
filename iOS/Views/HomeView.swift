//
//  ContentView.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 6/30/20.
//  Copyright © 2020 liamrosenfeld. All rights reserved.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @State private var pushed = false
    @State private var inputImage: UIImage?
    
    init() {
        // Set global NavBar style
        let appearance = UINavigationBar.appearance()
        
        // set colors
        appearance.barTintColor = UIColor(named: "NavBar")
        appearance.tintColor = .white
        
        // turn off the default behavior that messes up the colors
        appearance.isTranslucent = false
        appearance.shadowImage = nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    
                    Logo()
                        
                    Spacer()

                    PickerButton(image: $inputImage)

                    Spacer()

                    CameraButton(image: $inputImage)

                    Spacer()
                    Spacer()
                    Spacer()

                    HStack {
                        Spacer()
                        InfoButton()
                    }
                }

                // link to next view
                NavigationLink(destination: AsciiView(image: $inputImage), isActive: $pushed) { EmptyView() }
            }
            .navigationBarHidden(true)
        }.onChange(of: inputImage) { image in
            guard image != nil else { return }
            pushed = true
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Logo: View {
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 0, maxHeight: 300)
                .padding(.all, 10)
                .padding(.top, 20)
        } else {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.all, 10)
                .padding(.top, 15)
        }
    }
}

struct PickerButton: View {
    @Binding var image: UIImage?
    @State private var showingPickerSheet = false

    var body: some View {
        Button(action: {
            showingPickerSheet = true
        }, label: {
            Text(Image(systemName: "photo")) + Text(" Pick Image")
        })
        .buttonStyle(FullWidthStyle())
        .accessibility(label: Text("Pick Image"))
        .sheet(isPresented: $showingPickerSheet) {
            PhotoPickerView(image: $image)
        }
    }
}

struct CameraButton: View {
    @Binding var image: UIImage?
    
    @State private var showingCameraSheet = false
    @State private var showingCameraAlert = false
    
    var body: some View {
        Button(action: {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                showingCameraSheet = true
            } else {
                showingCameraAlert = true
            }
        }, label: {
            Text(Image(systemName: "camera")) + Text(" Take Picture")
            
        })
        .buttonStyle(FullWidthStyle())
        .accessibility(label: Text("Take Picture"))
        .sheet(isPresented: $showingCameraSheet) {
            CameraView(image: $image)
                .edgesIgnoringSafeArea(.all)
        }.alert(isPresented: $showingCameraAlert) {
            Alert(title: Text("No Camera Available"))
        }
    }
}

struct InfoButton: View {
    @State private var showingInfoSheet = false
    
    var body: some View {
        Button(action: {
            showingInfoSheet = true
        }, label: {
            Image(systemName: "info.circle")
                .foregroundColor(.white)
                .font(.system(size: 30))
                .padding(.all, 20)
        }).sheet(isPresented: $showingInfoSheet) {
            InfoView()
        }.accessibility(label: Text("Info"))
    }
}

struct FullWidthStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .grayText : .white)
            .font(.system(size: 25))
            .foregroundColor(.white)
            .padding(40)
            .frame(maxWidth: .infinity)
            .background(Color.button)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDevice("iPhone 11")
            HomeView()
                .previewDevice("iPhone 8")
            HomeView()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
        }
    }
}
