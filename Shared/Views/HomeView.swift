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
                Color("DarkBlue")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all, 20)

                    Spacer()
                    Spacer()

                    ZStack {
                        Rectangle()
                            .fill(Color("LightBlue"))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 90)

                        Button(action: {
                            showingPickerSheet = true
                        }, label: {
                            Image(systemName: "photo")
                            Text("Pick Image")
                        })
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .sheet(isPresented: $showingPickerSheet) {
                            PhotoPickerView(image: $inputImage)
                        }
                    }

                    Spacer()

                    ZStack {
                        Rectangle()
                            .fill(Color("LightBlue"))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 90)

                        Button(action: {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showingCameraSheet = true
                            } else {
                                showingAlert = true
                            }

                        }, label: {
                            Image(systemName: "camera")
                            Text("Take Picture")
                        })
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .sheet(isPresented: $showingCameraSheet) {
                            CameraView(image: $inputImage)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }

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
            }.navigationBarHidden(true)
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("No Camera Available"))
        }.onChange(of: inputImage) { image in
            guard image != nil else { return }
            pushed = true
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
