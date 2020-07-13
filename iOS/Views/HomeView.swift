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
    @State private var showingPickerSheet = false
    @State private var showingCameraSheet = false
    @State private var showingInfoSheet = false
    @State private var showingAlert = false
    @State private var inputImage: UIImage?

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all, 10)
                        .padding(.top, 15)

                    Spacer()

                    GetImageButton(camera: false, image: $inputImage)

                    Spacer()

                    GetImageButton(camera: true, image: $inputImage)

                    Spacer()
                    Spacer()
                    Spacer()

                    HStack {
                        Spacer()
                        Button(action: {
                            showingInfoSheet = true
                        }, label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .padding(.all, 20)
                        }).sheet(isPresented: $showingInfoSheet) {
                            InfoView()
                        }
                    }
                }

                // link to next view
                NavigationLink(destination: AsciiView(image: $inputImage), isActive: $pushed) { EmptyView() }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
        }.onChange(of: inputImage) { image in
            guard image != nil else { return }
            pushed = true
        }
    }
}

struct GetImageButton: View {
    let camera: Bool
    @Binding var image: UIImage?

    @State private var showingSheet = false
    @State private var showingCameraAlert = false

    var body: some View {
        Button(action: {
            if !camera || UIImagePickerController.isSourceTypeAvailable(.camera) {
                showingSheet = true
            } else {
                showingCameraAlert = true
            }
        }, label: {
            Image(systemName: camera ? "camera" : "photo")
            Text(camera ? "Take Picture" : "Pick Image")
        })
        .font(.system(size: 25))
        .foregroundColor(.white)
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.button)
        .sheet(isPresented: $showingSheet) {
            if camera {
                CameraView(image: $image)
                    .edgesIgnoringSafeArea(.all)
            } else {
                PhotoPickerView(image: $image)
            }
        }.alert(isPresented: $showingCameraAlert) {
            Alert(title: Text("No Camera Available"))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDevice("iPhone 11")
            HomeView()
                .previewDevice("iPhone 8")
        }
    }
}
