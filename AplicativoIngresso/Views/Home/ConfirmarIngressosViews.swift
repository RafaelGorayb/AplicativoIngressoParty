//
//  ConfirmarIngressosViews.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 20/07/23.
//

import SwiftUI

struct ConfirmarIngressosView: View {
    @EnvironmentObject var carrinhoVm: CarrinhoCompraViewModel
    @EnvironmentObject var compraVm: CompraViewModel
    @State var isConfirmed: Bool? = false
    @State var showConfirmationAlert = false
    @State private var lastCpfCount: Int = 0
    let costumerid: String
   
   var body: some View {
       List {
           Text("Dados do ingresso").font(.system(size: 24, weight: .bold)).gradientForeground(colors: [.rosa1, .roxo1]).listRowSeparator(.hidden)
           ForEach(Array(compraVm.compra.ingressos.enumerated()), id: \.offset) { index, _ in
               Section{
                   VStack(alignment: .leading){
                       Text("Ingresso \(index + 1)").font(.system(size: 14, weight: .bold))
                       Text("\(compraVm.compra.ingressos[index].tipoIngresso)-\(compraVm.compra.ingressos[index].numeroLote)º lote").font(.system(size: 12, weight: .medium))
                       FloatingTextField(placeholder: "Nome do Proprietário", text: $compraVm.compra.ingressos[index].proprietario)
                       FloatingTextField(placeholder: "Documento CPF", text: $compraVm.compra.ingressos[index].DocumentoCPF)
                           .keyboardType(.numberPad)
                           .onChange(of: compraVm.compra.ingressos[index].DocumentoCPF) { newValue in
                               if compraVm.compra.ingressos[index].DocumentoCPF.count > lastCpfCount {
                                   compraVm.compra.ingressos[index].DocumentoCPF = formatCPF(compraVm.compra.ingressos[index].DocumentoCPF)
                               } else {
                                   compraVm.compra.ingressos[index].DocumentoCPF = unformatCPF(compraVm.compra.ingressos[index].DocumentoCPF)
                               }
                               
                               lastCpfCount = compraVm.compra.ingressos[index].DocumentoCPF.count
                           }
                   }
               }
               .listRowSeparator(.hidden)
           }
           .listRowSeparator(.hidden)
       }
       .listStyle(.plain)
       .navigationBarTitle("Titularidade dos Ingressos", displayMode: .inline)
       .navigationBarItems(trailing:
            Button(action: {
           let allInputsValid = compraVm.compra.ingressos.allSatisfy { ingresso in
                    isCPFValid(cpf: ingresso.DocumentoCPF) && isNomeValid(nome: ingresso.proprietario)
                }
                
                if allInputsValid {
                    self.showConfirmationAlert = true
                } else {
                    // Você pode mostrar uma mensagem de erro aqui
                    print("Nome ou CPF inválido")
                }
            }) {
                Text("Confirmar")
            }
       .alert(isPresented: $showConfirmationAlert) {
           Alert(
               title: Text("Confirmação"),
               message: Text("Os dados estão corretos? Somente será possivel edita-los após a compra."),
               primaryButton: .default(Text("Sim"), action: {
                   // Navigate to CheckoutView
                   isConfirmed = true
               }),
               secondaryButton: .cancel(Text("Não"))
           )
       }
       )
       .background(
           NavigationLink(
            destination: CheckoutView(costumerId: costumerid).navigationBarBackButtonHidden(true),
               tag: true,
               selection: $isConfirmed,
               label: {
                   EmptyView()
               })
           )
   }
    
    private func isCPFValid(cpf: String) -> Bool {
        if cpf.count == 14 {
            return true
        } else{
            return false
        }
    }

    private func isNomeValid(nome: String) -> Bool {
        // Um nome é válido se não está vazio.
        return !nome.isEmpty
    }
}


struct ConfirmarIngressosView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmarIngressosView(costumerid: "").environmentObject(CompraViewModel()).environmentObject(CarrinhoCompraViewModel())
    }
}
