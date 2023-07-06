//
//  AnimatedPlaceholder.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 06/07/23.
//

import SwiftUI

struct AnimatedPlaceholder: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = false
    var body: some View {
        ZStack(alignment: .center){
            VStack{
                Image(systemName: "ticket").scaleEffect(4)
                    .rotationEffect(Angle(degrees: 135))
                Spacer()
                HStack{
                    Rectangle()
                        .fill(.gray)
                        .frame(width: UIScreen.main.bounds.width * 0.15, height: 50)
                        .cornerRadius(12)
                    VStack(alignment: .leading){
                        Rectangle()
                            .fill(.gray)
                            .frame(width: UIScreen.main.bounds.width * 0.5, height: 20)
                            .cornerRadius(12)
                        Rectangle()
                            .fill(.gray)
                            .frame(width: UIScreen.main.bounds.width * 0.7, height: 20)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 150)
        .opacity(isLoading ? 0.1 : 0.3)
        .foregroundColor(colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
        .onAppear{
            withAnimation(Animation.linear(duration: 0.5).repeatForever()){
                isLoading = true
            }
        }
        .onDisappear{
            isLoading = false
        }
    }
}

struct AnimatedPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPlaceholder()
    }
}
