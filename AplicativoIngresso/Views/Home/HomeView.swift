//
//  HomeView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 16/03/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var eventoVm: EventoViewModel
    @EnvironmentObject var userVm: UserViewModel
    @State private var searchText = ""
    var body: some View {
        NavigationStack{
                VStack{
                    List{
                        HStack{
                            Text("Procurando eventos em")
                            Text("Campinas")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                        .listRowSeparator(.hidden)
                        bototesGenerosFesta().environmentObject(eventoVm)
                            .frame(height: 50)
                            .listRowSeparator(.hidden)
                        ForEach(eventoVm.currentEventos.filter({ "\($0.tituloEvento)".contains(searchText) || searchText.isEmpty }).indices, id: \.self) { index in
                            let evento = eventoVm.currentEventos.filter({ "\($0.tituloEvento)".contains(searchText) || searchText.isEmpty })[index]
                            
                            ZStack {
                                NavigationLink(destination: DetailEventoView(evento: evento).environmentObject(userVm)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                .buttonStyle(PlainButtonStyle())

                                EventoHomeItem(evento: evento)
                                    .shadow(radius: 5)
                                    .zIndex(1)
                                    .listRowSeparator(.hidden)
                                    
                                    // Se este for o último item da lista, carregamos mais
                                    .onAppear {
                                        if index == eventoVm.currentEventos.filter({ "\($0.tituloEvento)".contains(searchText) || searchText.isEmpty }).count - 1 {
                                            eventoVm.fetchDbData()
                                        }
                                    }
                            }
                        }


                        
                    }
                    .refreshable {
                        eventoVm.eventos = []
                        eventoVm.lastDocument = nil
                        eventoVm.fetchDbData()
                        
                    }
                    .onAppear{
                        eventoVm.fetchDbData()
                    }
                    .listStyle(.plain)
                }
                .toolbar{
                    CustomSearchBar(text: $searchText)
                        .onChange(of: searchText) { text in
                            if text.isEmpty {
                                eventoVm.eventosFiltrados = []
                            } else {
                                eventoVm.searchEventos(query: text) { eventos in
                                    DispatchQueue.main.async {
                                        eventoVm.eventosFiltrados = eventos
                                    }
                                }
                            }
                        }

                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .shadow(radius: 20)
                        .zIndex(1)
                        .listRowSeparator(.hidden)
                        .padding(.bottom)
                }

                .navigationTitle(" ")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}


