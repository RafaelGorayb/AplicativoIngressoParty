//
//  ProcessPaymentDetails.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 17/07/23.
//

import SwiftUI
import StripePaymentSheet



struct CheckoutView: View {
    @EnvironmentObject var carrinhoVm: CarrinhoCompraViewModel
    @EnvironmentObject var compraVm: CompraViewModel
    @State var isConfirmingPayment = false
    @State private var isShowingPgtConfirm = false
    @State private var isShowingCancelAlert = false
    @State var resultado = ""
    @Environment(\.presentationMode) var presentationMode
    var costumerId: String
    
    var body: some View {
        NavigationStack{
            VStack {
                
                if let paymentSheetFlowController = carrinhoVm.paymentSheetFlowController {
                    HStack {
                        Text("Concluir pagamento").font(.system(size: 24, weight: .bold)).gradientForeground(colors: [.rosa1, .roxo1]).listRowSeparator(.hidden)
                        Spacer()
                    }
                    Spacer()
                    //BOTAO DE OPCOES DE PAGAMENTO
                    PaymentSheet.FlowController.PaymentOptionsButton(
                        paymentSheetFlowController: paymentSheetFlowController,
                        onSheetDismissed: carrinhoVm.onOptionsCompletion
                    ) {
                        PaymentOptionView(
                            paymentOptionDisplayData: paymentSheetFlowController.paymentOption)
                    }
                    Spacer()
                    Divider()
                    //LISTA COM RESUMO DO PEDIDO
                    VStack {
                        ForEach(Array(carrinhoVm.carrinho.ingressos.enumerated()), id: \.offset) { index, ingressoCarrinho in
                            HStack{
                                Text("\(ingressoCarrinho.quantidade)x")
                                    .font(.system(size: 14, weight: .bold))
                                Text("\(ingressoCarrinho.tipo) - \(ingressoCarrinho.lote.numerolote)º lote")
                                    .font(.system(size: 14, weight: .light))
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Text("Taxas: \(carrinhoVm.totalTax.formatted(.currency(code: "brl")))") //taxas
                                .font(.system(size: 10, weight: .light))
                                .padding(.leading, 25)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Total: ") //Total
                            Spacer()
                            Text("\(carrinhoVm.totalFinalAmount.formatted(.currency(code: "brl")))")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .padding(.top)
                        
                    }
                    .padding()
                    
                    NavigationLink(destination: CheckoutResultView(paymentIntentId: carrinhoVm.paymentIntentId).environmentObject(carrinhoVm).environmentObject(compraVm).toolbar(.hidden), isActive: $isShowingPgtConfirm) {
                        EmptyView()
                    }
                    
                    //BOTAO PARA FINALIZAR A COMPRA
                    CustomPaymentButton(isConfirmingPayment: $isConfirmingPayment)
                        .paymentConfirmationSheet(
                            isConfirming: $isConfirmingPayment,
                            paymentSheetFlowController: paymentSheetFlowController,
                            onCompletion: { result in
                                // Execute a lógica existente após o pagamento ser concluído
                                carrinhoVm.onCompletion(result: result)
                                
                                switch result {
                                case .completed:
                                    compraVm.addCompra(compraVm.compra, statusCompra: "aprovado") { (documentId, error) in
                                        if let error = error {
                                            print("Erro ao adicionar compra: \(error.localizedDescription)")
                                        } else if let documentId = documentId {
                                            carrinhoVm.updatePaymentIntentMetadata(documentId: documentId, eventoId: compraVm.compra.eventoId)
                                            EventoViewModel().atualizarIngressosVendidos(carrinho: carrinhoVm.carrinho) { error in
                                                if let error = error {
                                                    print("Ocorreu um erro ao atualizar os ingressos: \(error.localizedDescription)")
                                                } else {
                                                    print("Ingressos atualizados com sucesso!")
                                                    self.isShowingPgtConfirm = true
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                    print("Pagamento feito com sucesso pelo usuário")
                                    
                                case .failed(let error):
                                    print("Falha no pagamento: \(error.localizedDescription)")
                                    
                                case .canceled:
                                    print("Pagamento cancelado")
                                }
                            }
                        )
                        .disabled(paymentSheetFlowController.paymentOption == nil || isConfirmingPayment)
                    
                } else {
                    ExampleLoadingView()
                }
                if let result = carrinhoVm.paymentResult {
                    PaymentStatusView(result: result)
                }
            }
            .padding()
            .onAppear { carrinhoVm.preparePaymentSheets(customerID: costumerId, carrinho: carrinhoVm.carrinho) }
            .toolbar{
                Button("Cancelar", action: {
                    isShowingCancelAlert = true   // defina esta variável como verdadeira quando o botão for pressionado
                })
                .alert(isPresented: $isShowingCancelAlert) {
                    Alert(
                        title: Text("Cancelar Pagamento"),
                        message: Text("Tem certeza de que deseja cancelar o pagamento?"),
                        primaryButton: .destructive(Text("Cancelar Pagamento")) {
                            carrinhoVm.cancelPaymentIntent(){ result in
                                switch result {
                                case .success:
                                    print("O PaymentIntent foi cancelado com sucesso.")
                                    DispatchQueue.main.async {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    
                                case .failure(let error):
                                    print("Erro ao cancelar o PaymentIntent: \(error)")
                                }
                            }
                        },
                        secondaryButton: .cancel(Text("Manter Pagamento"))
                    )
                }
            }
        }
    }
}


struct CustomPaymentButton: View {
    @Binding var isConfirmingPayment: Bool
    @EnvironmentObject var carrinhoVm: CarrinhoCompraViewModel

    var body: some View {
        Button(action: {
            // Atualize o PaymentIntent aqui se necessário e defina isConfirmingPayment para true após a atualização estar concluída
            isConfirmingPayment = true
        }) {
            if isConfirmingPayment {
                ProgressView()  // A animação de carregamento pode ser personalizada de acordo com suas necessidades
            } else {
                Text("Pagar")  // Coloque a lógica para calcular o total do carrinho aqui
            }
        }
        .buttonStyle(CustomButtonStyle())
        .disabled(carrinhoVm.paymentSheetFlowController?.paymentOption == nil || isConfirmingPayment)
        .frame(minWidth: 200)
        .background(Color.clear)
        .padding()
        .cornerRadius(6)
    }
}


struct ExampleLoadingView: View {
    var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
        } else {
            Text("Preparando pagamento…")
        }
    }
}

struct PaymentStatusView: View {
    let result: PaymentSheetResult

    var body: some View {
        HStack {

            switch result {
            case .completed:
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Text("Success!")
                
                                
            case .failed(let error):
                Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
                Text("Falha no pagamento: \(error.localizedDescription )")
                    .font(.system(size: 12.0))
            case .canceled:
                Image(systemName: "xmark.octagon.fill").foregroundColor(.orange)
                Text("Pagamento cancelado.")
            }
        }
        .accessibility(identifier: "Payment status view")
    }
}

struct PaymentOptionView: View {
    let paymentOptionDisplayData: PaymentSheet.FlowController.PaymentOptionDisplayData?

    var body: some View {
        HStack {
            Image(uiImage: paymentOptionDisplayData?.image ?? UIImage(systemName: "creditcard")!)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 30, maxHeight: 30, alignment: .leading)
                .foregroundColor(.black)
            Text(paymentOptionDisplayData?.label ?? "Selecione um meio de pagamento")
                // Surprisingly, setting the accessibility identifier on the HStack causes the identifier to be
                // "Payment method-Payment method". We'll set it on a single View instead.
                .accessibility(identifier: "Payment method")
        }
        .frame(minWidth: 200)
        .padding()
        .foregroundColor(.black)
        .background(Color.init(white: 0.9))
        .cornerRadius(6)
    }
}

struct ExampleSwiftUICustomPaymentFlow_Preview: PreviewProvider {
    static var previews: some View {
        CheckoutView(costumerId: "cus_OI0TaaweB50eBv").environmentObject(CarrinhoCompraViewModel())
    }
}
