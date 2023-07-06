//
//  liveCircle.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 09/07/23.
//

import SwiftUI

struct liveCircle: View {
    @Binding var isAnimating: Bool
    @State private var opacity: Double = 0.2

    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(isAnimating ? .green : .gray)
            .opacity(opacity)
            .onAppear {
                if isAnimating {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        opacity = 1
                    }
                }
            }
            .onDisappear {
                opacity = 1
            }
    }
}

struct liveCircle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack{
                liveCircle(isAnimating: .constant(false))
                liveCircle(isAnimating: .constant(true))
            }
        }
    }
}



