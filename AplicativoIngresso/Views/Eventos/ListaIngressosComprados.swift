//
//  ListaIngressosComprados.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI

struct ListaIngressosComprados: View {
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var compraVm: CompraViewModel
    @State var compraSelecionada: Compra?
    @State var showTicket = false
        var body: some View {
            NavigationStack{
                List{
                    ForEach(compraVm.compras, id: \.id){ compra in
                        NavigationLink(destination: ticketView(compra: compra), label: {
                            ingressoListItem(compra: compra)
                                .padding(.top)
                                .padding(.bottom)
                        })
                    }
                }
                .listStyle(.plain)
                .onAppear{
                    compraVm.fetchComprasData(proprietarioId: userVm.uuid ?? "n/a")
                }
                .refreshable {
                    compraVm.fetchComprasData(proprietarioId: userVm.uuid ?? "n/a")

                }
                .navigationTitle("Meus ingressos")
            }
        }
    }

struct ListaIngressosComprados_Previews: PreviewProvider {
    static var previews: some View {
        ListaIngressosComprados().environmentObject(CompraViewModel()).environmentObject(UserViewModel())
    }
}
