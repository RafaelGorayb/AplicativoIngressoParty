//
//  ContentView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 16/03/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var eventoVm: EventoViewModel
    var body: some View {
        
        TabView{
            HomeView()
                .environmentObject(eventoVm).environmentObject(userVm)
                .tabItem {
                    VStack {
                        Label("Home", systemImage: "house")
                    }
                }
            
            ListaEventos().environmentObject(eventoVm).environmentObject(userVm).environmentObject(CompraViewModel())
                .tabItem({
                    Label("Eventos", systemImage: "ticket")
                })
            
            PerfilView()
                .tabItem({
                    Label("Perfil", systemImage: "person")
                })
        }
        .background(Color.white)
        .accentColor(.pink)
        .onAppear{
            userVm.sync()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserViewModel())
            .environmentObject(EventoViewModel())
            .environmentObject(CompraViewModel())
        
    }
}
