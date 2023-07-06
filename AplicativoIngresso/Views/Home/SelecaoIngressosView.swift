import SwiftUI

struct SelecaoIngressosView: View {
    let evento: Evento
    @EnvironmentObject var carrinhoVm: CarrinhoCompraViewModel
    @EnvironmentObject var compraVm: CompraViewModel
    @EnvironmentObject var userVm: UserViewModel
    @State var showAuthView = false
    @FocusState private var isButtonFocused: Bool
    @Binding var showSelecaoIngressos: Bool
    
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    HStack{
                        Text("Selecione um ingresso")
                            .gradientForeground(colors: [.rosa1,.roxo1])
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    
                    //Lista o ingresso disponivel do lote de menor numero disponivel
                    ForEach(Array(evento.ingressos.enumerated()), id: \.offset) { index, ingresso in
                        if ingresso.disponibilidade {
                            let availableLots = ingresso.lote.filter { $0.disponibilidade }
                            let minPriceLot = availableLots.min { a, b in a.preco < b.preco }
                            if let minPriceLot = minPriceLot {
                                VStack {
                                    Spacer()
                                    HStack {
                                        //listar o numero de ingressos para comprar e atualizar adicionando e removendo conforme a quantidade selecionada
                                        Menu {
                                            ForEach(0..<(min(4, minPriceLot.qtdDisponivel - minPriceLot.qtdVendida + 1))) { number in
                                                Button("\(number)") {
                                                    //atualizar carrinho com os ingressos selecionados para calcular o valor da compra
                                                    carrinhoVm.updateCart(for: ingresso, lot: minPriceLot, quantity: number)
                                                    
                                                    //criar ingressos no array para serem adicionados ao banco
                                                    compraVm.adicionarIngresso(for: ingresso, lot: minPriceLot, quantity: number, eventoId: evento.id ?? "", proprietarioIngressoId: userVm.uuid ?? "", nomeEvento: evento.tituloEvento, dataEvento: evento.dataInicio, urlFotoCapaEvento: evento.urlFotoCapa)
                                                }
                                            }
                                        } label: {
                                            Text("\(carrinhoVm.selecionados["\(ingresso.tipo)-\(minPriceLot.numerolote)", default: 0])")
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .border(.gray)
                                        }
                                        
                                        Spacer()
                                        HStack{
                                            Label(ingresso.tipo, systemImage: "ticket")
                                            Text("\(minPriceLot.numerolote)º lote")
                                            Spacer()
                                        }
                                        .padding(.leading)
                                        Spacer()
                                        Text("\(minPriceLot.preco.formatted(.currency(code: "brl")))")
                                    }
                                    .padding(5)
                                    .foregroundColor(.black)
                                    .font(.system(size: 12, weight: .regular))
                                    Spacer()
                                    Divider()
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .navigationTitle("Seleção de ingressos").navigationBarTitleDisplayMode(.inline)
                .listStyle(.plain)
                
                //lista dos ingressos selecionados.
                //Valores totais para pagamento e taxas
                //
                Divider()
                VStack{
                    ForEach(Array(carrinhoVm.carrinho.ingressos.enumerated()), id: \.offset) { index, ingressoCarrinho in
                        HStack{
                            Text("\(ingressoCarrinho.quantidade)x")
                                .font(.system(size: 14, weight: .bold))
                            Text("\(ingressoCarrinho.tipo) - \(ingressoCarrinho.lote.numerolote)º lote")
                                .font(.system(size: 14, weight: .light))
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Text("Taxas: \(carrinhoVm.totalTax.formatted(.currency(code: "brl")))") //taxas
                            .font(.system(size: 10, weight: .light))
                            .padding(.leading, 25)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Total: ") //Total
                        Spacer()
                        Text("\(carrinhoVm.totalFinalAmount.formatted(.currency(code: "brl")))")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .padding(.top)
                    
                    if userVm.userIsAuthenticatedAndSynced {
                        NavigationLink(destination: ConfirmarIngressosView(costumerid: userVm.user?.stripeId ?? "").environmentObject(carrinhoVm).environmentObject(compraVm), label: {

                                Text("Confirmar ingressos")
                                    //
                                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 40)
                                    .foregroundColor(.white) // Cor do texto
                                    .background(RadialGradient(colors: [.rosa1, .roxo1], center: .bottomLeading, startRadius: 0, endRadius: 150))
                                    .cornerRadius(12) // Raio de borda arredondado
                                    .scaleEffect(isButtonFocused ? 1.1 : 1.0)
                                    .animation(.default, value: isButtonFocused)
                                    .shadow(radius: 10)
                                    .focused($isButtonFocused)
                        })
                    } else{
                       Button("Fazer login", action: {
                           showAuthView = true
                       })
                       .buttonStyle(CustomButtonStyle())
                    }
                                        
                }
                .padding()
            }
            .sheet(isPresented: $showAuthView, content: {
                AuthenticationView()
            })
        }
    }
}

struct SelecaoIngressosView_Previews: PreviewProvider {
    static var previews: some View {
        SelecaoIngressosView(
            evento: Evento(
            proprietarioEvento: "65465465",
            colaboradoresEvento: [],
            tituloEvento: "Entrosa Bixo 2023",
            descricao: "O Carnaval ainda não chegou, mas o after já tá garantido!✨ \n\nBixos e bixetes, o primeiro open bar da Morsa do ano já tem data marcada e é a maior e melhor integração com seus veteranos 💚 \n\nAnota aí no seu calendário, dia 16 de março é dia de fazer o que a gente mais gosta: beber muuuuuita breja gelada e Juquinha, e integrar com muita tinta e glitter! 🍻",
            dataInicio: Date(),
            dataFim: Date(),
            status: "Ativo",
            local: "Campinas Hall",
            ingressos: [
                TipoIngresso(tipo: "Pista", disponibilidade: true, lote: [
                    Lote(numerolote: 1, disponibilidade: false, preco: 100, qtdDisponivel: 5, qtdVendida: 5),
                    Lote(numerolote: 2, disponibilidade: true, preco: 180, qtdDisponivel: 4, qtdVendida: 0)
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
            ),
            showSelecaoIngressos:  .constant(true))
        .environmentObject(CarrinhoCompraViewModel()).environmentObject(CompraViewModel()).environmentObject(UserViewModel())
    }
}


extension Binding where Value == Int? {
    func replacingNil(with replacement: Int) -> Binding<Int> {
        return .init(
            get: { return self.wrappedValue ?? replacement },
            set: { newValue in self.wrappedValue = newValue }
        )
    }
}





