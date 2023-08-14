//
//  invitePromoterView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 13/08/23.
//

import SwiftUI

struct invitePromoterView: View {
    let evento: Evento
    var body: some View {
        NavigationStack{
            VStack{
                Text("Distribua o código abaixo para que outras pessoas possam ingressar na equipe de seu evento.")
                    .font(.system(size: 14, weight: .regular))
                HStack{
                    Text("Código do evento: ").font(.system(size: 12))
                    Text("\(evento.id ?? "")").font(.system(size: 12, weight: .light)).foregroundColor(.gray)
                }
                .padding()
                Button(action: {
                    UIPasteboard.general.string = evento.id ?? ""
                    print(evento.id ?? "")
                }, label: {
                    Label("Copiar código", systemImage: "rectangle.on.rectangle")
                   
                })
                .buttonStyle(CustomButtonStyle())
                .padding()
            }
            .navigationTitle("Enviar convites")
        }
    }
}

struct invitePromoterView_Previews: PreviewProvider {
    static var previews: some View {
        invitePromoterView(evento: Evento(
            proprietarioEvento: "",
            colaboradoresEvento: [],
            tituloEvento: "Entrosa Bixo 2023",
            descricao: "O Carnaval ainda não chegou, mas o after já tá garantido!✨ \n\nBixos e bixetes, o primeiro open bar da Morsa do ano já tem data marcada e é a maior e melhor integração com seus veteranos 💚 \n\nAnota aí no seu calendário, dia 16 de março é dia de fazer o que a gente mais gosta: beber muuuuuita breja gelada e Juquinha, e integrar com muita tinta e glitter! 🍻",
            dataInicio: Date(),
            dataFim: Date(),
            status: "Ativo",
            local: "Campinas Hall",
            ingressos: [
                TipoIngresso(tipo: "Pista", disponibilidade: true, lote: [
                    Lote(numerolote: 1, disponibilidade: true, preco: 100, qtdDisponivel: 2, qtdVendida: 1),
                    Lote(numerolote: 2, disponibilidade: false, preco: 180, qtdDisponivel: 4, qtdVendida: 0)
                ]),
                
                TipoIngresso(tipo: "Camarote", disponibilidade: true, lote: [
                    Lote(numerolote: 1, disponibilidade: true, preco: 250, qtdDisponivel: 3, qtdVendida: 2)
                ])
            ],
            tipoBar: false,
            urlFotoCapa: "https://firebasestorage.googleapis.com:443/v0/b/party-ca1c3.appspot.com/o/images%2FE7F4AFE1-067B-48AE-A4B9-36652578B4A1?alt=media&token=5f55a94d-1f6a-454b-863a-9999f44c2864", //
            tipoFesta: ["Funk", "Pagode"], // Array com uma String vazia
            lojaEvento: [
                ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: ""), //
                ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: "") //
            ]
        ))
    }
}
