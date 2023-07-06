//
//  ListaEventos.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI

struct ListaEventos: View {
    @EnvironmentObject var eventoVm: EventoViewModel
    @EnvironmentObject var userVm: UserViewModel
    @State var addEventoSheet = false
    @State var loginSheet = false
    @State var confirmationDialog = false
    @State var selectedView = 0
    var body: some View {
        NavigationStack{
                VStack{
                if userVm.userIsAuthenticatedAndSynced{
                    Picker("", selection: $selectedView){
                        Text("Ingressos").tag(0)
                        Text("Eventos").tag(1)
                    }.padding().pickerStyle(.segmented)
                    
                    if selectedView == 0 {
                        ListaIngressosComprados().environmentObject(userVm).environmentObject(CompraViewModel())
                    }
                    if selectedView == 1 {
                        ListaEventosAdm().environmentObject(eventoVm).environmentObject(userVm)
                    }
                }
                    else{
                        AuthenticationView()
                    }
                    

            }
            .navigationTitle("Meus eventos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                if selectedView == 1 {
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
                            
                        }
                    })
                }else{
                    
                }
            }
            .onAppear{
                if userVm.userIsAuthenticatedAndSynced{
                    selectedView = 0
                }
                else{
                    selectedView = 0
                }

            }
            .sheet(isPresented: $addEventoSheet, content: {
                AdicionarEventoView().environmentObject(EventoViewModel())
            })
            
        }
    }
}

struct ListaEventos_Previews: PreviewProvider {
    static var previews: some View {
        ListaEventos().environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}
