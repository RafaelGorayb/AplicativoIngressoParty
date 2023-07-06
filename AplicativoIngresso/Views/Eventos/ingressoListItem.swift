//
//  ingressoListItem.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 30/07/23.
//

import SwiftUI

struct ingressoListItem: View {
    let compra: Compra
    @State private var imageLoaded = false
    @State private var isAnimating = false
    var body: some View {
            HStack{
                AsyncImage(url: URL(string: compra.urlFotoCapaEvento)) { image in
                    image.resizable()
                        .frame(width: 60, height: 60)
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .onAppear {
                            imageLoaded = true
                        }
                } placeholder: {
                    AnimatedPlaceholder()
                    
                }
                
                if imageLoaded {
                    VStack(alignment: .leading){
                        Spacer()
                        Text(compra.nomeEvento)
                            .font(.system(size: 14, weight: .medium))
                        
                        Text(compra.dataEvento.formatDate())
                            .font(.system(size: 12, weight: .light))
                        Spacer()
                        Text("\(compra.ingressos.count) ingressos")
                            .font(.system(size: 14, weight: .regular))
                        Spacer()
                    }
                    Spacer()
//                    Button(action:{} , label: {
//                        HStack{
//                            liveCircle(isAnimating: $isAnimating)
//                            Text("Em andamento")
//                                .font(.system(size: 14, weight: .regular))
//                                .foregroundColor(.verde1)
//                        }
//                    })
                }
                Spacer()
                
            }
            .frame(height: 60)
    }
}


struct ingressoListItem_Previews: PreviewProvider {
    static var previews: some View {
        ingressoListItem(compra: Compra(eventoId: "WOZNZ4ys30ykIOUaeNKk",
                                        proprietarioIngressoId: "VYRo7ojh6lYMEmRK9amQBbSaihC3",
                                        nomeEvento: "Show the weekend",
                                        dataEvento: Date(),
                                        urlFotoCapaEvento: "https://firebasestorage.googleapis.com:443/v0/b/party-ca1c3.appspot.com/o/images%2F74AA027A-3189-46DF-9A7B-8CE1252FDFFA?alt=media&token=158299dd-a811-49fc-8fbc-c8d821ed2187",
                                        statusCompra: "aprovado",
                                        ingressos: [Ingresso(proprietario: "Rafael",
                                                             DocumentoCPF: "36911234816",
                                                             tipoIngresso: "Entrada normal",
                                                             numeroLote: 2,
                                                             validade: true)]))
    }
}
