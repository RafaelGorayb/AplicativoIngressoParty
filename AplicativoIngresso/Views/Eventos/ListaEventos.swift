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
    @EnvironmentObject var compraVm: CompraViewModel
    @State var loginSheet = false
    var body: some View {
        NavigationStack{
                VStack{
                    switch userVm.userIsAuthenticatedAndSynced{
                    case true:
                      
                        ListaIngressosComprados().environmentObject(userVm).environmentObject(compraVm)
                            .onAppear{
                                compraVm.fetchComprasData(proprietarioId: userVm.uuid ?? "n/a")
                            }
                    
                    case false:
                        AuthenticationView()
                    }
                    
            }
            .navigationTitle("Meus ingressos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{

            }
            .onAppear{

            }
        }
    }
}

struct ListaEventos_Previews: PreviewProvider {
    static var previews: some View {
        ListaEventos().environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}
