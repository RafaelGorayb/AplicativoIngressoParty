//
//  DadosEventoviEW.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 18/08/23.
//

import SwiftUI

//struct DadosEventoView: View {
//    @EnvironmentObject var viewModel: DadosEventoViewModel
//    @EnvironmentObject var userVm: UserViewModel
//    @EnvironmentObject var eventoVm: EventoViewModel
//    let evento: Evento
//    @State private var editarSheet = false
//    @State private var editEvento = false
//    @State private var inviteColab = false
//
//    var body: some View {
//        NavigationStack{
//            List{
//                HStack{
//                    Spacer()
//                    VStack{
//                        Text("\(viewModel.totalIngressosVendidos())").font(.system(size: 32, weight: .bold)).gradientForeground(colors: [.rosa1, .roxo1])
//                        Text("Ingressos vendidos")
//                    }
//                    Spacer()
//                }
//                .padding(.top, 40)
//                .listRowSeparator(.hidden)
//
//                Section(content: {
//
//                    //itens
//                    ForEach(viewModel.evento.ingressos, id: \.tipo) { tipoIngresso in
//                        if let lote = viewModel.loteDisponivelMaisBaixo(tipoIngresso: tipoIngresso) {
//                            DadosEventoRow(
//                                tipoIngresso: tipoIngresso,
//                                lote: lote,
//                                porcentagemVendidaMenorLote: viewModel.porcentagemVendida(lote: lote),
//                                porcentagemVendidaTotal: viewModel.porcentagemVendidaTotal(tipoIngresso: tipoIngresso)
//                            )
//                        }
//
//                    }
//
//                }, header: {
//                    Text("Ingressos e lotes atuais").gradientForeground(colors: [.rosa1, .roxo1])
//                        .padding(.top,20)
//
//                })
//
//                .listRowSeparator(.hidden)
//            }
//            .onAppear{
//                viewModel.evento = evento
//            }
//            .listStyle(.plain)
//            .navigationTitle("Dados Evento")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar{
//                Button(action: {
//                    eventoVm.evento = evento
//                    eventoVm.selectedImage = nil
//                    editarSheet = true
//                }, label: {
//                    HStack{
//                        Text("Opções")
//                        Image(systemName: "square.and.pencil")
//                    }
//
//
//                })
//
//            }
//            .customConfirmDialog(isPresented: $editarSheet, actions: {
//                //botao para editar
//                Button(action: {
//                    eventoVm.evento = evento
//                    eventoVm.selectedImage = nil
//                    editEvento = true
//                }, label: {
//                    HStack{
//                        Image(systemName: "square.and.pencil").frame(width: 40)
//                        Text("Editar evento")
//                    }
//                })
//
//                    Divider()
//
//                Button(action: {
//                    eventoVm.evento = evento
//                    inviteColab = true
//                }, label: {
//                    HStack{
//                        Image(systemName: "person.fill.badge.plus").frame(width: 40)
//                        Text("Convidar colaborador")
//                    }
//
//                })
//
//                Divider()
//
//                Button(action: {
//
//                }, label: {
//                    HStack{
//                        Image(systemName: "person.3.sequence.fill").frame(width: 40)
//                        Text("Ver colaboradores")
//                    }
//                })
//            })
//            .sheet(isPresented: $editEvento, content: {
//                EditarEventoView().environmentObject(eventoVm).environmentObject(userVm)
//            })
//
//            .sheet(isPresented: $inviteColab, content: {
//                invitePromoterView(evento: eventoVm.evento)
//                    .presentationDetents([.fraction(0.4)])
//            })
//        }
//    }
//}


struct DadosEventoView: View {
    @EnvironmentObject var viewModel: DadosEventoViewModel
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var eventoVm: EventoViewModel
    let evento: Evento
    @State private var editarSheet = false
    @State private var editEvento = false
    @State private var inviteColab = false
    @State private var tipoIngressoExpandido: String? = nil  // Variável para controlar o Tipo de Ingresso expandido

    var body: some View {
        NavigationStack{
            List{
                HStack{
                    Spacer()
                    VStack{
                        Text("\(viewModel.totalIngressosVendidos())")
                            .font(.system(size: 32, weight: .bold))
                            .gradientForeground(colors: [.rosa1, .roxo1])
                        Text("Ingressos vendidos")
                    }
                    Spacer()
                }
                .padding(.top, 40)
                .listRowSeparator(.hidden)
                
                Section(content: {
                    ForEach(viewModel.evento.ingressos, id: \.tipo) { tipoIngresso in
                        VStack {
                            HStack {
                                if let lote = viewModel.loteDisponivelMaisBaixo(tipoIngresso: tipoIngresso) {
                                    DadosEventoRow(
                                        tipoIngresso: tipoIngresso,
                                        lote: lote,
                                        porcentagemVendidaMenorLote: viewModel.porcentagemVendida(lote: lote),
                                        porcentagemVendidaTotal: viewModel.porcentagemVendidaTotal(tipoIngresso: tipoIngresso)
                                    )
                                }

                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                    if tipoIngressoExpandido == tipoIngresso.tipo {
                                        tipoIngressoExpandido = nil
                                    } else {
                                        tipoIngressoExpandido = tipoIngresso.tipo
                                    }
                                }


                            // Se esta linha estiver expandida, exiba os detalhes de todos os Lotes para este Tipo de Ingresso.
                                if tipoIngressoExpandido == tipoIngresso.tipo {
                                    ForEach(tipoIngresso.lote, id: \.numerolote) { lote in
                                        HStack {
                                            Text("Lote \(lote.numerolote): \(lote.qtdVendida)/\(lote.qtdDisponivel.description) vendidos")
                                            Spacer()
                                        }
                                        .background(.gray).opacity(0.5)
                                        .padding(.leading)
                                        
                                    }
                            }

                        }
                    }
                }, header: {
                    Text("Ingressos e lotes atuais")
                        .gradientForeground(colors: [.rosa1, .roxo1])
                        .padding(.top,20)
                })
                .listRowSeparator(.hidden)
            }
            .onAppear{
                viewModel.evento = evento
            }
            .listStyle(.plain)
            .navigationTitle("Dados Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button(action: {
                    eventoVm.evento = evento
                    eventoVm.selectedImage = nil
                    editarSheet = true
                }, label: {
                    HStack{
                        Text("Opções")
                        Image(systemName: "square.and.pencil")
                    }
                })
            }
                        .customConfirmDialog(isPresented: $editarSheet, actions: {
                            //botao para editar
                            Button(action: {
                                eventoVm.evento = evento
                                eventoVm.selectedImage = nil
                                editEvento = true
                            }, label: {
                                HStack{
                                    Image(systemName: "square.and.pencil").frame(width: 40)
                                    Text("Editar evento")
                                }
                            })
            
                                Divider()
            
                            Button(action: {
                                eventoVm.evento = evento
                                inviteColab = true
                            }, label: {
                                HStack{
                                    Image(systemName: "person.fill.badge.plus").frame(width: 40)
                                    Text("Convidar colaborador")
                                }
            
                            })
            
                            Divider()
            
                            Button(action: {
            
                            }, label: {
                                HStack{
                                    Image(systemName: "person.3.sequence.fill").frame(width: 40)
                                    Text("Ver colaboradores")
                                }
                            })
                        })
            .sheet(isPresented: $editEvento, content: {
                EditarEventoView().environmentObject(eventoVm).environmentObject(userVm)
            })
            .sheet(isPresented: $inviteColab, content: {
                invitePromoterView(evento: eventoVm.evento)
                    .presentationDetents([.fraction(0.4)])
            })
        }
    }
}

struct DadosEventoRow: View {
    let tipoIngresso: TipoIngresso
    let lote: Lote
    let porcentagemVendidaMenorLote: Double
    let porcentagemVendidaTotal: Double

    var body: some View {
        VStack{
            HStack {
                Text(tipoIngresso.tipo)
                    .font(.system(size: 18, weight: .medium))
                    .frame(minWidth: 120, alignment: .leading)
                
                VStack(alignment: .center) {
                    Text("Lote \(lote.numerolote)/\(tipoIngresso.lote.count)")
                    Text("\(porcentagemVendidaMenorLote, specifier: "%.0f")%")
                        .font(.caption)
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(minWidth: 70)
                
                Text("\(porcentagemVendidaTotal, specifier: "%.0f")%")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(minWidth: 100, alignment: .trailing)
            }
            Divider()
        }
    }
}


struct DadosEventoView_Previews: PreviewProvider {
    static var previews: some View {
        DadosEventoView(evento: Evento(
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
                    Lote(numerolote: 1, disponibilidade: true, preco: 100, qtdDisponivel: 1550, qtdVendida: 890),
                    Lote(numerolote: 2, disponibilidade: false, preco: 180, qtdDisponivel: 1550, qtdVendida: 0)
                ]),
                
                TipoIngresso(tipo: "Camarote", disponibilidade: true, lote: [
                    Lote(numerolote: 1, disponibilidade: true, preco: 250, qtdDisponivel: 780, qtdVendida: 652)
                ])
            ],
            tipoBar: false,
            urlFotoCapa: "https://firebasestorage.googleapis.com:443/v0/b/party-ca1c3.appspot.com/o/images%2FE7F4AFE1-067B-48AE-A4B9-36652578B4A1?alt=media&token=5f55a94d-1f6a-454b-863a-9999f44c2864", //
            tipoFesta: ["Funk", "Pagode"], // Array com uma String vazia
            lojaEvento: [
                ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: ""), //
                ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: "") //
            ]
            )).environmentObject(DadosEventoViewModel())
    }
}
