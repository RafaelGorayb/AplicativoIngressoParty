//
//  PaymentMethodsView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 22/07/23.
//

import Foundation
import SwiftUI
import StripePayments
import StripePaymentsUI


struct CardListView: View {
    @ObservedObject var viewModel: CardListViewModel
    let customerId: String
    
    var body: some View {
        NavigationStack{
            Group {
                if viewModel.isLoading {
                    ProgressView()  // Será mostrado enquanto estiver carregando
                } else {
                    List(viewModel.cards) { card in
                        HStack{
                            Image(card.brand)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 60)


                            VStack(alignment: .leading) {
                                Text("**** \(card.last4)")
                                Text("Expira em: \(card.exp_month)/\(card.exp_year.description)")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .light))
                                }
                            }
                        .swipeActions{
                            Button(action: {
                                viewModel.deleteCard(id: card.id, customerId: customerId)
                            }, label: {
                                Label("", systemImage: "trash")
                            })
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                viewModel.loadCards(for: customerId)
            }
            .navigationTitle("Cartões cadastrados")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}









struct PaymentMethodsView_Preview: PreviewProvider {
    static var previews: some View {
        CardListView(viewModel: CardListViewModel(),customerId: "cus_OJOBqDuPmWcYEB")

    }
}
