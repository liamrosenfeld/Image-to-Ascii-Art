//
//  NavBarButton.swift
//  Image To Ascii Art
//
//  Created by Liam Rosenfeld on 7/13/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

struct NavBarStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .grayText : .white)
            .padding(10)
            .background(configuration.isPressed ? Color.pressedButton : Color.button)
            .cornerRadius(10)
    }
}
