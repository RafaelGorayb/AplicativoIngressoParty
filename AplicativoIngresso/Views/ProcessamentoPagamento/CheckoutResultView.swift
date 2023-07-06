//
//  CheckoutResultView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 23/07/23.
//

import SwiftUI
import StripePaymentSheet

struct CheckoutResultView: View {
    @EnvironmentObject var compraVm: CompraViewModel
    @EnvironmentObject var carrinhoVm: CarrinhoCompraViewModel
    var paymentIntentId: String
    @State var iconName = ""
    @State var statusLabel = ""
    @State var statusDescription = ""
    @State var color: Color = .gray
    @State var showIngresso = false

    var body: some View {
        VStack {
            if let paymentIntent = carrinhoVm.paymentIntent {
                VStack{
                    Spacer()
                    Image(systemName: iconName)
                        .resizable()
                        .frame(width: 90, height: 90)
                        .scaledToFit()
                        .foregroundColor(color)
                    
                    Text(statusLabel)
                        .font(.system(size: 20, weight: .bold))
                    Text(statusDescription)
                        .font(.system(size: 16, weight: .regular))
                        .padding(.top)
                    
                    Spacer()
                    
                    if statusLabel == "Sucesso"{
                        Button("Visualizar ingresso", action: {
                            showIngresso = true
                        }).buttonStyle(CustomButtonStyle())
                    }
                    else {
                        Button("Fechar", action: {
                            //Fechar view
                        }).buttonStyle(CustomButtonStyle())
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .onAppear{
                    paymentStatus(status: paymentIntent.status)
                }
            } else {
                Text("Loading...")
            }
        }
        .onAppear() {
            carrinhoVm.getPaymentIntent()
        }
        .navigationDestination(isPresented: $showIngresso) {
            ticketView(compra: compraVm.compra)
       }
    }
    
    func paymentStatus (status: String) {
        switch status{
        case  "succeeded":
            iconName = "checkmark.circle.fill"
            statusLabel = "Sucesso"
            statusDescription = "O pagamento foi aprovado e seu ingresso ja esta disponível."
            color = .green
            
        case  "processing":
            iconName = "exclamationmark.circle.fill"
            statusLabel = "Processando"
            statusDescription = "O pagamento foi aprovado e seu ingresso ja esta disponível."
            color = .yellow

        default:
            iconName = "checkmark.circle.fill"
            statusLabel = "Processando"
            statusDescription = "O pagamento foi aprovado e seu ingresso ja esta disponível."
            color = .yellow
                
        }
    }
}




struct FailCheckoutResult: View{
    @State var showIngresso = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .resizable()
                .frame(width: 90, height: 90)
                .scaledToFit()
                .foregroundColor(.red)
                
            Text("Falha no pagamento.")
                .font(.system(size: 20, weight: .bold))
            Text("O pagamento foi recusado pela administradora do cartão. ")
                .font(.system(size: 16, weight: .regular))
                .padding(.top)
                
            Spacer()
            Button("Tentar novamente", action: {
                presentationMode.wrappedValue.dismiss()
            }).buttonStyle(CustomButtonStyle())
            Spacer()
        }
        .navigationDestination(isPresented: $showIngresso) {
           // ticketView()
       }
        .padding(40)
    }
}




struct CheckoutResultView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            CheckoutResultView(paymentIntentId: "pi_3NZjLpERPZEdqIxu1vak5lgx").environmentObject(CompraViewModel())
        }
    }
}
