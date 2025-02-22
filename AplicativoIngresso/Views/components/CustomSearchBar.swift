//
//  CustomSearchBar.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 06/07/23.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("Pesquisar eventos...", text: $text)
                .padding(7)
                .frame(height: 50)
                .padding(.horizontal, 50)
                .background(Color(.systemGray6))
                .cornerRadius(25)
                .foregroundColor(.black)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.black)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }

            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            
            }
        }
    }
}

//struct CustomSearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomSearchBar()
//    }
//}
