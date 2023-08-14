//
//  ValidationCard.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 12/08/23.
//

import SwiftUI

struct ValidationCard: View {
        let info: TicketInfo
        let isTicketValid: Bool?
        let validationMessage: String
        let eventoId: String
        var actionOnClose: () -> Void

        var body: some View {
            VStack {
                VStack{
                    if eventoId != info.eventoId {
                        Text("Ingresso nao pertencente ao evento")
                        Button("Próximo QR Code") {
                            actionOnClose()
                        }
                    } else {
                        switch isTicketValid{
                        case true:
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.green)
                                .scaleEffect(2)
                        case false:
                            Image(systemName: "exclamationmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.red)
                                .scaleEffect(2)
                        case nil:
                            ProgressView()
                            
                        case .some(_):
                            Text("erro tente novamente")
                        }
   
                        Text(validationMessage)
                            .font(.system(size: 18, weight: .bold))
                            .padding()
                        
                        VStack{
                            VStack(alignment: .leading){
                                Text("\(info.proprietarioNome)")
                                Text("CPF:\(info.documentoCPF)")
                                Text("\(info.tipoIngresso)")
                            }
                            .padding()
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .background(.gray.opacity(0.3))
                        .cornerRadius(12)
                        
                        Button("Próximo QR Code") {
                            actionOnClose()
                        }
                        .buttonStyle(CustomButtonStyle())
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 300)
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
        }
        
    }


struct ValidationCard_Previews: PreviewProvider {
    static var previews: some View {
        ValidationCard(
            info: TicketInfo(eventoId: "UjkhklJHlkhjhl",
                             compraId: "hhshjsakk=ASDOLA",
                             dataEvento: Date(),
                             ingressoId: "AAS654-ADAAA-5455AS4-ADAA",
                             proprietarioNome: "Rafael Gorayb",
                             documentoCPF: "369.112.348-16",
                             tipoIngresso: "Pista"),
            isTicketValid: true,
            validationMessage: "Ingresso Válido!",
            eventoId: "UjkhklJHlkhjhl",
            actionOnClose: {}
        )
    }
}
