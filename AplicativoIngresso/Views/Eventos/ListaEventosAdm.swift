//
//  ListaEventosAdm.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI

struct ListaEventosAdm: View {
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var eventoVm: EventoViewModel
    @State var isActive = false
    @State var editEvento = false
    @State var confirmationDialog = false
    var body: some View {
        VStack{
            List{
                ForEach(eventoVm.eventos, id: \.id){ evento in
                    EventoOwnerItem(evento: evento).environmentObject(userVm)
                        .shadow(radius: 20)
                        .padding(.bottom)
                        .padding(.top)
                        .contextMenu{
                            //botao para editar
                            Button(action: {
                                eventoVm.evento = evento
                                editEvento = true
                            }, label: {
                                Label("Editar", systemImage: "pencil")
                            })
                            
                            Button(action: {
                               //Código para ler qrcode
                            }, label: {
                                Label("Ler QRcode", systemImage: "qrcode")
                            })
                            
                            Button(action: {
                               //codigo para copiar id do evento e compartilhar
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
    }
}

struct ListaEventosAdm_Previews: PreviewProvider {
    static var previews: some View {
        ListaEventosAdm().environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}
