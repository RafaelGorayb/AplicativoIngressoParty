//
//  insertEventCodeView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 13/08/23.
//

import SwiftUI

struct InsertEventCodeView: View {
    let userId: String
    @Binding var isPresented: Bool
    @State private var eventCode: String = ""
    @State private var successMessageIsVisible: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack {
                FloatingTextField(placeholder: "Insira o código aqui", text: $eventCode)
                 
                
                Button("Adicionar") {
                    //função para adicionar o evento usando o código.
                   EventoViewModel().addPromoter(eventoId: eventCode, userId: userId){
                         successMessageIsVisible = true
                     }
                }
                .buttonStyle(CustomButtonStyle())
                .alert(isPresented: $successMessageIsVisible) {
                    Alert(title: Text("Sucesso"), message: Text("Evento adicionado com sucesso!"), dismissButton: .default(Text("OK"), action: {
                        isPresented = false
                    }))
                }
            }
            .padding()
            .navigationTitle("Inserir código de evento")
        }
    }
}


struct insertEventCodeView_Previews: PreviewProvider {
    static var previews: some View {
        InsertEventCodeView(userId: "JH3UB3UBAHUI", isPresented: .constant(true))
    }
}
