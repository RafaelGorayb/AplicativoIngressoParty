//
//  DetailEventoView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 06/07/23.
//

import SwiftUI

struct DetailEventoView: View {
    @FocusState private var isButtonFocused: Bool
    @EnvironmentObject var userVm: UserViewModel
    @State private var imageLoaded = false
    @State var comprarSheet = false
    @State var isShowingTicket = false
    let evento: Evento
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    ZStack{
                        AsyncImage(url: URL(string: evento.urlFotoCapa)) { image in
                               image.resizable()
                                .frame(height: 200)
                                .scaledToFit()
                                .blur(radius: 20)
                                .ignoresSafeArea()
                                 .onAppear {
                                     imageLoaded = true
                                 }
                            
                        } placeholder: {
                            AnimatedPlaceholder()
                               
                        }
                    
                    

                        AsyncImage(url: URL(string: evento.urlFotoCapa)) { image in
                               image.resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: 150)
                                .cornerRadius(12)
                                 .onAppear {
                                     imageLoaded = true
                                 }
                            
                        } placeholder: {
                            AnimatedPlaceholder()
                               
                        }
                    }
                    Spacer()
                    Text(evento.tituloEvento)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black).opacity(0.95)
                    VStack{
                        Text(formatDate(evento.dataInicio))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black).opacity(0.95)
                        HStack{
                            Label(formatTime(evento.dataInicio), systemImage: "clock")
                            Label(evento.local.description, systemImage: "mappin")
                        }
                        
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black).opacity(0.95)
                        


                        HStack {
    
                            Text(getFormattedPriceRange())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black).opacity(0.95)
                            }
                    }
                    Divider()
                    Spacer()
                }
                .foregroundColor(.black).opacity(0.75)
                .navigationTitle("Evento").navigationBarTitleDisplayMode(.inline)
                
                VStack(alignment: .leading){
                    Text("Descricão do evento")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black).opacity(0.95)
                    
                    
                    Text(evento.descricao)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black).opacity(0.95)
                        .padding(.top, 5)
                    
                    
                }
                .padding(30)
            }
            Button(action: {
                comprarSheet = true
            }) {
                Text("Comprar ingressos")
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 40) 
                    .foregroundColor(.white) // Cor do texto
                    .background(RadialGradient(colors: [.rosa1, .roxo1], center: .bottomLeading, startRadius: 0, endRadius: 150))
                    .cornerRadius(12) // Raio de borda arredondado
                    .scaleEffect(isButtonFocused ? 1.1 : 1.0)
                    .animation(.default, value: isButtonFocused)
            }
            .shadow(radius: 10)
            .focused($isButtonFocused)
            
            .sheet(isPresented: $comprarSheet, content: {
                SelecaoIngressosView(evento: evento, showSelecaoIngressos: $comprarSheet).environmentObject(CarrinhoCompraViewModel()).environmentObject(CompraViewModel()).environmentObject(userVm)
            })
                        
            .toolbar{
             Button(action: {
                 
             }, label: {
                 Image(systemName: "")
             })
            }
        }
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR") // Português do Brasil
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMMyyyy")
        return dateFormatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "pt_BR") // Português do Brasil
        timeFormatter.setLocalizedDateFormatFromTemplate("HHmm")
        return timeFormatter.string(from: date)
    }
    
    func getFormattedPriceRange() -> String {
        let precos = evento.ingressos
            .filter { $0.disponibilidade } // considera apenas ingressos disponíveis
            .flatMap { $0.lote } // extrai todos os lotes
            .filter { $0.disponibilidade } // considera apenas lotes disponíveis
            .map { $0.preco } // extrai os preços
        
        let precoMin = precos.min() ?? 0.0
        let precoMax = precos.max() ?? 0.0

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        
        let precoMinFormatado = formatter.string(from: NSNumber(value: precoMin)) ?? "R$0.00"
        let precoMaxFormatado = formatter.string(from: NSNumber(value: precoMax)) ?? "R$0.00"

        return "De \(precoMinFormatado) até \(precoMaxFormatado)"
    }

}


struct DetailEventoView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEventoView(
            evento: Evento(
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
            )
        ).environmentObject(UserViewModel())
    }
}
