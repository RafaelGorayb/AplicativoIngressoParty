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
    @EnvironmentObject var userVm: UserViewModel
    @State var proprietarioUser = false
    @State var isConfirmed: Bool? = false
    @State var showConfirmationAlert = false
    @State private var lastCpfCount: Int = 0
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    @State private var currentAlert: AlertType? = nil

    let costumerid: String
   
   var body: some View {
       List {
           Text("Dados do ingresso").font(.system(size: 24, weight: .bold)).gradientForeground(colors: [.rosa1, .roxo1]).listRowSeparator(.hidden)

           ForEach(Array(compraVm.compra.ingressos.enumerated()), id: \.offset) { index, ingresso in
               Section {
                   IngressoSection(index: index, ingresso: $compraVm.compra.ingressos[index]).environmentObject(userVm)
               }
               .listRowSeparator(.hidden)
           }
           .listRowSeparator(.hidden)
       }


       .listStyle(.plain)
       .navigationBarTitle("Titularidade dos Ingressos", displayMode: .inline)
       .navigationBarItems(trailing:
            Button(action: {
                for (index, ingresso) in compraVm.compra.ingressos.enumerated() {
                    if !isNomeValid(nome: ingresso.proprietario) {
                        errorMessage = "O nome do ingresso \(index + 1) é inválido."
                        currentAlert = .error
                        return
                    }
                    
                    if !isCPFValid(cpf: ingresso.DocumentoCPF) {
                        errorMessage = "O CPF do ingresso \(index + 1) é inválido."
                        currentAlert = .error
                        return
                    }
                }

                if errorMessage == nil {
                    currentAlert = .confirmation
                }
            }) {
                Text("Confirmar")
            }



        .alert(item: $currentAlert) { alertType in
            switch alertType {
            case .confirmation:
                return Alert(
                    title: Text("Confirmação"),
                    message: Text("Os dados estão corretos? Somente será possivel edita-los após a compra."),
                    primaryButton: .default(Text("Sim"), action: {
                        // Navigate to CheckoutView
                        isConfirmed = true
                    }),
                    secondaryButton: .cancel(Text("Não"))
                )
            case .error:
                return Alert(
                    title: Text("Erro"),
                    message: Text(errorMessage ?? "Erro desconhecido"),
                    dismissButton: .default(Text("Ok")) {
                        errorMessage = nil // Reset the error message
                    }
                )
            }
        })

       .background(
           NavigationLink(
            destination: CheckoutView(costumerId: costumerid).environmentObject(carrinhoVm).environmentObject(compraVm).navigationBarBackButtonHidden(true),
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

    enum AlertType: Identifiable {
        case confirmation
        case error

        var id: Int {
            switch self {
                case .confirmation: return 1
                case .error: return 2
            }
        }
    }



}

struct IngressoSection: View {
    var index: Int
    @EnvironmentObject var userVm: UserViewModel
    @Binding var ingresso: Ingresso
    @State var toggle = false
    @State private var lastCpfCount: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ingresso \(index + 1)").font(.system(size: 14, weight: .bold))
                    Text("\(ingresso.tipoIngresso)-\(ingresso.numeroLote)º lote").font(.system(size: 12, weight: .medium))
                }

                Toggle(isOn: $toggle) {
                    HStack{
                        Spacer()
                        Text("Usar meus dados").font(.system(size: 12, weight: .medium)).gradientForeground(colors: [.rosa1,.roxo1])
                    }
                }
                .onChange(of: toggle) { isOn in
                    if isOn {
                        ingresso.proprietario = userVm.user?.nome ?? ""
                        ingresso.DocumentoCPF = userVm.user?.cpf ?? ""
                    } else {
                        ingresso.proprietario = ""
                        ingresso.DocumentoCPF = ""
                    }
                }
            }
            
            FloatingTextField(placeholder: "Nome do Proprietário", text: $ingresso.proprietario)
            FloatingTextField(placeholder: "Documento CPF", text: $ingresso.DocumentoCPF)
            .keyboardType(.numberPad)
            .onChange(of: ingresso.DocumentoCPF) { newValue in
                if ingresso.DocumentoCPF.count > lastCpfCount {
                    ingresso.DocumentoCPF = formatCPF(ingresso.DocumentoCPF)
                } else {
                    ingresso.DocumentoCPF = unformatCPF(ingresso.DocumentoCPF)
                }
                lastCpfCount = ingresso.DocumentoCPF.count
            }
        }
    }
}


struct ConfirmarIngressosView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmarIngressosView(costumerid: "").environmentObject(CompraViewModel()).environmentObject(CarrinhoCompraViewModel())
    }
}
