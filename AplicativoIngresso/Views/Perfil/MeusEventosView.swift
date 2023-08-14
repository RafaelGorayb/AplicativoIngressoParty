//
//  MeusEventosView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 09/08/23.
//

import SwiftUI

struct MeusEventosView: View {
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var eventoVm: EventoViewModel
    @State var isActive = false
    @State var lerQrcode = false
    @State var addEventoSheet = false
    @State var editEvento = false
    @State var inviteColab = false
    @State var confirmationDialog = false
    @State var insertEventCodeSheet = false
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    ForEach(eventoVm.eventosProprios, id: \.id){ evento in
                        NavigationLink(destination: OpcoesDadosView(evento: evento).environmentObject(DadosEventoViewModel(evento: evento)).environmentObject(userVm).environmentObject(eventoVm), label: {
                            EventoOwnerItem(evento: evento).environmentObject(userVm)
                        })
                        .shadow(radius: 20)
                        .padding(.bottom)
                        .padding(.top)
                            .contextMenu{
                                //botao para editar
                                Button(action: {
                                    eventoVm.evento = evento
                                    eventoVm.selectedImage = nil
                                    editEvento = true
                                }, label: {
                                    Label("Editar", systemImage: "pencil")
                                })
                                
                                Button(action: {
                                    eventoVm.evento = evento
                                    lerQrcode = true
                                }, label: {
                                    Label("Ler QRcode", systemImage: "qrcode")
                                })
                                
                                Button(action: {
                                    eventoVm.evento = evento
                                    inviteColab = true
                                }, label: {
                                    Label("Convidar colaborador", systemImage: "person.fill.badge.plus")
                                })
                                
                                Button(action: {
                                    //codigo para copiar id do evento e compartilhar
                                }, label: {
                                    Label("Editar lotes", systemImage: "ticket")
                                })
                            }
                        
                    }
                }
                .listStyle(.plain)
            }
            .onAppear{
                eventoVm.fetchEventosPropriosData(userId: userVm.uuid ?? "n/A")
            }
            .sheet(isPresented: $editEvento, content: {
                EditarEventoView().environmentObject(eventoVm).environmentObject(userVm)
            })
            .sheet(isPresented: $lerQrcode, content: {
                QRCodeScannerViewView(eventoId: eventoVm.evento.id ?? "").environmentObject(QrcodeScannerViewModel())
            })
            .sheet(isPresented: $inviteColab, content: {
                invitePromoterView(evento: eventoVm.evento)
                    .presentationDetents([.fraction(0.4)])
            })
            
            .navigationTitle("Meus eventos")
            .toolbar{
                Button(action: {
                    confirmationDialog = true
                }, label: {
                    Text("Novo evento")
                })
                .confirmationDialog("Novo evento", isPresented: $confirmationDialog, actions: {
                    Button("Criar novo evento"){
                        addEventoSheet = true
                    }
                    Button("Inserir código de evento"){
                        insertEventCodeSheet = true
                    }
                })
            }
            .sheet(isPresented: $addEventoSheet, content: {
                AdicionarEventoView().environmentObject(EventoViewModel())
            })
            .sheet(isPresented: $insertEventCodeSheet, content: {
                InsertEventCodeView(userId: userVm.uuid ?? "n/A", isPresented: $insertEventCodeSheet)
            })
        }
    }
}

struct MeusEventosView_Previews: PreviewProvider {
    static var previews: some View {
        MeusEventosView().environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}
