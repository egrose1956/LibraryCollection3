//
//  ButtonStyleConfig.swift
//  LibraryCollection3
//
//  Created by Elizabeth Rose on 2/29/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        if colorScheme == .dark {
            configuration.label
                .padding(5)
                .font(.subheadline)
                .background(Color.accentColor)
                .foregroundStyle(Color.black)
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
                
        } else {
            configuration.label
                .padding(5)
                .font(.subheadline)
                .background(Color.accentColor)
                .foregroundStyle(Color.white)
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
                
        }

    }
}
