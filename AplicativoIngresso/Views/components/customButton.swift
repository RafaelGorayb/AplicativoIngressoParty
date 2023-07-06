//
//  customButton.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 10/07/23.
//

import SwiftUI

struct customButton: View {
    var body: some View {
        VStack{
          
            Button(action: {
                
            }, label: {
                HStack{
                    Image("googleIcon")
                    Text("Entrar com o google")
                }
            }).buttonStyle(GoogleButton())
            
            Button("Comprar ingressos", action: {
                
            }).buttonStyle(CustomButtonStyle())
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ?
                        RadialGradient(colors: [.roxo1], center: .bottomLeading, startRadius: 0, endRadius: 150) : RadialGradient(colors: [.rosa1, .roxo1], center: .bottomLeading, startRadius: 0, endRadius: 150))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .shadow(radius: 12)
    }
}

struct GoogleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.white)
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(radius: 12)
            
            
    }
}


struct customButton_Previews: PreviewProvider {
    static var previews: some View {
        customButton()
    }
}
