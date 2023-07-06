//
//  ColorBorderStyle.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 17/07/23.
//

import Foundation
import SwiftUI

struct ColorBorderStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(colorScheme == .light ? Color.blue : Color.white, lineWidth: 2)
            )
    }
}

extension View {
    func addColorBorderStyle() -> some View {
        modifier(ColorBorderStyle())
    }
}
