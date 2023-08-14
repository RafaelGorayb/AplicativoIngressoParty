
//
//  ChargesListView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 07/08/23.
//

import SwiftUI

struct ChargesListView: View {
    @EnvironmentObject var viewModel: ChargeListViewModel
    let customerId: String
    
    var body: some View {
        NavigationStack{
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.charges) { charge in
                        ChargeItem(charge: charge)
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                // Substitua pelo ID de cliente real
                viewModel.loadCharges(for: customerId)
            }
            .navigationTitle("Compras")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct ChargeItem: View{
    let charge: Charge
    var body: some View{
        HStack{
            
            VStack(alignment: .leading, spacing: 0){
                Text(Date(timeIntervalSince1970: Double(charge.created)).formattedAsString())
                    .font(.system(size: 10, weight: .light))
                HStack(spacing: 0){
                    Image(charge.payment_method_details.card.brand)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text(charge.payment_method_details.card.last4)
                        .font(.system(size: 10, weight: .light))
                }
            }
            Spacer()
            Text(charge.status)
                .font(.system(size: 12, weight: .regular))
            Spacer()
            Text("\((charge.amount/100).formatted(.currency(code: "brl")))")
                .font(.system(size: 12, weight: .regular))
           
        }
    }
}




struct ChargesListView_Previews: PreviewProvider {
    static var previews: some View {
        ChargesListView(customerId: "cus_OJOBqDuPmWcYEB").environmentObject(ChargeListViewModel())
        ChargeItem(charge: Charge(id: "j3hj34kh4k", amount: 10000, created: 1691376566, currency: "brl", description: "2 tickets", status: "Aprovado", payment_method_details: PaymentMethodDetails(card: CardDetails(brand: "visa", last4: "4242"))))
    }
}
