//
//  CustomTextField.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI

struct FloatingTextField: View {
    @State var color: Color = .gray
    let placeholder: String
    @Binding var text: String
    
    
    var body: some View {
        ZStack (alignment: .leading) {
            Text(placeholder)
                .foregroundColor(.gray)
                .offset(y: self.text.isEmpty ? 0  : -25)
                .scaleEffect(self.text.isEmpty ? 1 : 0.9, anchor: .leading)
                .font(.system(self.text.isEmpty ? .body : .footnote))
            
            TextField("", text: self.$text)
                .fontWeight(.medium)
                
        }
        .padding(.top, self.text.isEmpty ? 0 : 18)
        .animation(.default, value: !text.isEmpty)
        .padding()
        .frame(height:50)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 0.5)
        )
        .cornerRadius(8)

    }
}

struct FloatingDoubleTextField: View {
    @State var color: Color = .gray
    @State private var text: String = ""
    let placeholder: String
    @Binding var value: Double

    var body: some View {
        let binding = Binding<String>(
            get: {
                self.text
            },
            set: {
                self.text = $0
                if let doubleValue = Double($0) {
                    self.value = doubleValue
                } else if $0.isEmpty {
                    self.value = 0
                }
            }
        )

        return FloatingTextField(color: color, placeholder: placeholder, text: binding)
            .onAppear {
                self.text = String(format: "%.2f", self.value)
            }
    }
}




struct FloatingIntTextField: View {
    @State var color: Color = .gray
    @State private var text: String
    let placeholder: String
    @Binding var value: Int
    
    init(color: Color = .gray, placeholder: String, value: Binding<Int>) {
        self.color = color
        self.placeholder = placeholder
        self._value = value
        self._text = State<String>(initialValue: String(value.wrappedValue))
    }
    
    private var textBinding: Binding<String> {
        Binding<String>(
            get: { String(self.value) },
            set: {
                self.text = $0
                if let intValue = Int($0) {
                    self.value = intValue
                }
            }
        )
    }
    
    var body: some View {
        FloatingTextField(color: color, placeholder: placeholder, text: textBinding)
    }
}






struct SecureFloatingTextField: View {
    @State var color: Color = .gray
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack (alignment: .leading) {
            Text(placeholder)
                .foregroundColor(.gray)
                .offset(y: self.text.isEmpty ? 0  : -25)
                .scaleEffect(self.text.isEmpty ? 1 : 0.9, anchor: .leading)
                .font(.system(self.text.isEmpty ? .body : .footnote))
            
            SecureField("", text: self.$text)
                .fontWeight(.medium)
                
        }
        .padding(.top, self.text.isEmpty ? 0 : 18)
        .animation(.default, value: !text.isEmpty)
        .padding()
        .frame(height:50)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 0.5)
        )
        .cornerRadius(8)

    }
}

struct FloatingTextEditor: View {
    @State var color: Color = .gray
    let placeholder: String
    @Binding var text: String
    
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            Text(placeholder)
                .foregroundColor(.gray)
                .offset(y: -15)
                .scaleEffect(0.9, anchor: .leading)
                .font(.system( .footnote))
            
            TextEditor(text: self.$text)
                .fontWeight(.medium)
                
        }
        .frame(minHeight: 150)
        .padding(.top, 20)
        .padding(.leading, 18)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 0.5)
        )
        .cornerRadius(8)

    }
}



struct FloatingTextField_Previews: PreviewProvider {
    static var previews: some View {
        FloatingTextField(placeholder: "First Name", text: .constant("Teste"))
            .padding()
        
        SecureFloatingTextField(placeholder: "password", text: .constant(""))
        
        FloatingTextEditor(placeholder: "Descricao", text: .constant("Teste"))
    }
}
