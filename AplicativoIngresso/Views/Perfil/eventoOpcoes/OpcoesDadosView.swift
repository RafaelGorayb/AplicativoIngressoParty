//
//  OpcoesDadosView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 25/08/23.
//

import SwiftUI

struct OpcoesDadosView: View {
    @EnvironmentObject var eventoVm: EventoViewModel
    @EnvironmentObject var userVm: UserViewModel
    let evento: Evento
    var body: some View {
        NavigationStack{
            VStack{
                List{
                  NavigationLink(destination:  DadosEventoView(evento: evento).environmentObject(DadosEventoViewModel(evento: evento)).environmentObject(userVm).environmentObject(eventoVm), label: {
                      Text("Dashboard de vendas")
                  })
                    
                    NavigationLink(destination: EmptyView(), label: {
                        Text("Colaboradores")
                    })
                    
                    NavigationLink(destination: EmptyView(), label: {
                        Text("Histórico de ingressos validados")
                    })
                }
            }
        }
    }
}

struct OpcoesDadosView_Previews: PreviewProvider {
    static var previews: some View {
        OpcoesDadosView(evento: eventoDemo).environmentObject(UserViewModel()).environmentObject(EventoViewModel())
    }
}
