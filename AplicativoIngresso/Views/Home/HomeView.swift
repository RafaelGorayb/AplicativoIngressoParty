//
//  HomeView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 16/03/23.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: NavigationModel
    @EnvironmentObject var eventoVm: EventoViewModel
    @EnvironmentObject var userVm: UserViewModel
    @State private var searchText = ""
    var body: some View {
        NavigationStack() {
            VStack{
                List{
                    HStack{
                        Text("Procurando eventos em")
                        Text("Campinas")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                    .listRowSeparator(.hidden)
                    bototesGenerosFesta()
                        .frame(height: 50)
                        .listRowSeparator(.hidden)
                    ForEach(eventoVm.eventos.filter({ "\($0.tituloEvento)".contains(searchText) || searchText.isEmpty }), id: \.id){ evento in
                        ZStack {
                            NavigationLink(destination: DetailEventoView(evento: evento).environmentObject(userVm)) {
                                EmptyView()
                            }
                            .opacity(0) // torna o NavigationLink invisível
                            .buttonStyle(PlainButtonStyle()) // Remove o realce padrão

                            EventoHomeItem(evento: evento)
                                .shadow(radius: 5)
                                .zIndex(1)
                                .listRowSeparator(.hidden)
                        }
                    }

                }
                .refreshable {
                    eventoVm.fetchDbData()
                }
                .onAppear{
                    eventoVm.fetchDbData()
                }
                .listStyle(.plain)
            }
            .toolbar{
                ToolbarItem{
                    CustomSearchBar(text: $searchText)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .shadow(radius: 20)
                        .zIndex(1)
                        .listRowSeparator(.hidden)
                        .padding(.bottom)
                }
                
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: NavigationModel()).environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}


