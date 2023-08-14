//
//  TicketView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 31/07/23.
//


import SwiftUI
import SwiftUIPager
import CoreImage.CIFilterBuiltins

struct ticketView: View {
    @State var showOpcoes = false
    @StateObject var page1: Page = .first()
    @State private var editingProprietario: String = ""
    @State private var editingDocumentoCPF: String = ""
    @State private var selectedIndex: Int? = nil

    let compra: Compra


    var body: some View {
        NavigationStack {
            VStack{
                GeometryReader { proxy in
                    Pager(page: self.page1,
                          data: compra.ingressos.indices,
                          id: \.self) { index in
                        TicketDetailsView(compra: compra, index: index)
                            .offset(y: -150)
                        
                    }
                          .interactive(rotation: true)
                          .interactive(scale: 0.7)
                          .interactive(opacity: 0.5)
                          .itemSpacing(20)
                          .itemAspectRatio(0.8, alignment: .end)
                          .background(Color.gray.opacity(0.2))
                }
                
            }
            .navigationBarTitle("Ingressos", displayMode: .inline)
            .toolbar{
                Button("Opções", action: {
                    selectedIndex = page1.index
                    editingProprietario = compra.ingressos[selectedIndex ?? 0].proprietario
                    editingDocumentoCPF = compra.ingressos[selectedIndex ?? 0].DocumentoCPF
                    showOpcoes = true
                })
            }
            .sheet(isPresented: $showOpcoes, content: {
                NavigationStack{
                    List{
                        Section{
                            NavigationLink(destination: EditTicketView(
                                proprietario: $editingProprietario,
                                documentoCPF: $editingDocumentoCPF,
                                compra: compra,
                                index: page1.index),
                                           label: {
                                HStack{
                                    Text("Editar")
                                    Spacer()
                                    Image(systemName: "square.and.pencil")
                                }
                            })
    
                            NavigationLink(destination: transferirIngressoView(compra: compra).environmentObject(TransferenciaViewModel()), label: {
                                HStack{
                                    Text("Transferir")
                                    Spacer()
                                    Image(systemName: "arrow.left.arrow.right")
                                }
                            })
    
                            NavigationLink(destination: EmptyView(), label: {
                                HStack{
                                    Text("Vender")
                                    Spacer()
                                    Image(systemName: "person.line.dotted.person.fill")
                                }
                            })
                        }
                    }
                }
                .presentationDetents([.fraction(0.4)])
            })
        }
    }
}

struct EditTicketView: View {
    @Binding var proprietario: String
    @Binding var documentoCPF: String
    @State private var lastCpfCount: Int = 0
    let compra: Compra
    @Environment(\.presentationMode) var presentationMode
    let index: Int

    var body: some View {
        List {
            Section(header: Text("Editar Ingresso")) {
                FloatingTextField(placeholder: "Nome", text: $proprietario)
                FloatingTextField(placeholder: "CPF", text: $documentoCPF)
                    .keyboardType(.numberPad)
                    .onChange(of: documentoCPF) { newValue in
                        if documentoCPF.count > lastCpfCount {
                            documentoCPF = formatCPF(documentoCPF)
                        } else {
                            documentoCPF = unformatCPF(documentoCPF)
                        }
                        
                        lastCpfCount = documentoCPF.count
                    }
     
            }
            Section{
                Button("Salvar", action: {
                    CompraViewModel().updateIngresso(compraId: compra.id ?? "", ingressoId: compra.ingressos[index].ingressoId ?? "", novoCPF: documentoCPF, novoProprietarioIngressoId: proprietario)
                    { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                            print("Ingresso atualizado com sucesso!")
                        } else {
                            print("Erro ao atualizar o ingresso.")
                        }
                    }
                }).buttonStyle(CustomButtonStyle())
            }
        }.listStyle(.plain)
        .navigationTitle("Editar")

    }
}

struct transferirIngressoView: View {
    let compra: Compra
    @EnvironmentObject var transferVm: TransferenciaViewModel
    @State private var showAlert = false
    @State private var isLinkActive = false
    

    var body: some View {
        NavigationStack {
            
            List {
                Section(header:  Text("Selecione os ingressos").gradientForeground(colors: [.rosa1, .roxo1])){
                    ForEach(compra.ingressos, id: \.ingressoId){ingresso in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(ingresso.tipoIngresso) \(ingresso.numeroLote)o Lote")
                                Text(ingresso.ingressoId ?? "").font(.system(size: 10)).foregroundColor(.gray)
                            }
                            Spacer()
                            if transferVm.ingressosSelecionados.contains(where: { $0.ingressoId == ingresso.ingressoId }) {
                                Image(systemName: "checkmark").foregroundColor(Color.rosa1)
                            }
                        }
                        .onTapGesture {
                            if let index = transferVm.ingressosSelecionados.firstIndex(where: { $0.ingressoId == ingresso.ingressoId }) {
                                transferVm.ingressosSelecionados.remove(at: index)
                            } else {
                                transferVm.ingressosSelecionados.append(ingresso)
                            }
                            
                        }
                    }
                }
            }.onAppear{
                transferVm.compra = compra
                transferVm.remetenteProprietarioIngressoId = compra.proprietarioIngressoId
            }
            .listStyle(.plain)
                       .toolbar {
                           Button("Prosseguir") {
                               if transferVm.ingressosSelecionados.isEmpty {
                                   showAlert = true
                               } else {
                                   isLinkActive = true
                               }
                           }
                       }
                       .background(NavigationLink("", destination: PesquisarUserView().environmentObject(transferVm), isActive: $isLinkActive))
                       .navigationTitle("ingressos")
                       .alert(isPresented: $showAlert) {
                           Alert(title: Text("Atenção"), message: Text("Por favor, selecione pelo menos 1 ingresso."), dismissButton: .default(Text("OK")))
                       }
                   }
               }
           }

struct PesquisarUserView: View {
    @EnvironmentObject var transferVm: TransferenciaViewModel
    @State var email = ""
    @State var userFound: Bool? = nil
    @State var navigate = false
    
    var body: some View {
        NavigationStack {
            Text("\(transferVm.ingressosSelecionados.count) ingressos selecionados")
            VStack {
                FloatingTextField(placeholder: "Email de destino", text: $email)
                    .padding()
                
                // Caso userFound seja nil, a pesquisa ainda não foi realizada
                // Caso userFound seja true, o usuário foi encontrado
                // Caso userFound seja false, o usuário não foi encontrado
                switch userFound {
                case true:
                    Text("Usuário encontrado")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    HStack{
                        AsyncImage(url: URL(string: transferVm.fotoDestinatario)) { image in
                            image.resizable()
                        } placeholder: {
                           Image(systemName: "person.crop.circle.fill")
                                .frame(width: 50, height: 50)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
                        Text(transferVm.nicknameDestinatario)
                    }
                    NavigationLink("Continuar", destination: ConfirmarTransferenciaView().environmentObject(transferVm)) // Navega para a próxima tela
                        .buttonStyle(CustomButtonStyle())
                        .padding()
                case false:
                    Text("Usuário não encontrado")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    Button("Pesquisar", action: {
                        pesquisarUsuario()
                    })
                    .buttonStyle(CustomButtonStyle())
                    .padding()
                default:
                    Button("Pesquisar", action: {
                        pesquisarUsuario()
                    })
                    .buttonStyle(CustomButtonStyle())
                    .padding()
                }
            }
        }
    }
    
    func pesquisarUsuario() {
        transferVm.findUser(email: email) { userId, urlFotoPerfil, nome, error in
            if let userId = userId, let urlFotoPerfil = urlFotoPerfil, let nome = nome {
                transferVm.destinatarioProprietarioIngressoId = userId
                transferVm.fotoDestinatario = urlFotoPerfil
                transferVm.nicknameDestinatario = nome
                userFound = true
                navigate = true
            } else if error != nil {
                userFound = false
            } else {
                userFound = false
            }
        }
    }
}

struct ConfirmarTransferenciaView: View {
    @EnvironmentObject var transferVm: TransferenciaViewModel
    @State private var showAlert = false
    @State private var transferSuccess = false

    var body: some View {
        VStack {
            Text("Transferir para \(transferVm.nicknameDestinatario)")
            Image(systemName: "person.line.dotted.person.fill").resizable().frame(width: 70, height: 70).scaledToFit()

            Button("Confirmar Transferência") {
                            transferirIngressos()
                        }
            .buttonStyle(CustomButtonStyle()).padding()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text(transferSuccess ? "Sucesso" : "Erro"), message: Text(transferSuccess ? "Ingressos transferidos com sucesso." : "Houve um erro na transferência. Por favor, tente novamente."), dismissButton: .default(Text("OK")))
                        }
                    }
                }

    func transferirIngressos() {
        transferVm.transferirIngressos { success in
            if success {
                transferSuccess = success
                showAlert = true
                CompraViewModel().fetchComprasData(proprietarioId: transferVm.remetenteProprietarioIngressoId)
                print("Transferência de ingressos bem-sucedida!")
            } else {
                print("A transferência de ingressos falhou.")
            }
        }

    }
}







struct TicketDetailsView: View {
    let compra: Compra
    let index: Int
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
                    .overlay{
                        //elemento formato do 'TICKET'
                        ZStack{
                            VStack{
                                Circle()
                                    .frame(width: 80, height: 100)
                                    .foregroundColor(.red)
                                    .blendMode(.destinationOut)
                                    .offset(y: -60)
                                Spacer()
                            }
                            //elementos do ticket
                            VStack{
                                HStack{
                                    Image("logoParty")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 60)
                                        .padding(.leading, 40)
                                        .rotationEffect(Angle(degrees: 20))
                                    
                                    Spacer()
                                    VStack{
                                        Text(compra.dataEvento.formatDate())
                                            .font(.system(size: 10, weight: .regular))
                                            .padding(.trailing, 40)
                                        Text(compra.dataEvento.formatTime())
                                            .font(.system(size: 10, weight: .regular))
                                            .padding(.trailing, 25)
                                    }
                                    .padding(.leading)
                                    
                                }
                                .frame(height: 45)
                                
                                AsyncImage(url: URL(string: compra.urlFotoCapaEvento)) { image in
                                    image.resizable()
                                        .frame(height: 130)
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                                                
                                VStack{
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("EVENTO")
                                                .font(.system(size: 12, weight: .medium))
                                                .gradientForeground(colors: [.pink, .purple])
                                            Text(compra.nomeEvento)
                                                .font(.system(size: 16, weight: .regular))
                                            
                                        }
                                        Spacer()
                                        VStack(alignment: .leading){
                                            Text("INGRESSO")
                                                .font(.system(size: 12, weight: .medium))
                                                .gradientForeground(colors: [.pink, .purple])
                                            Text("\(index + 1)/\(compra.ingressos.count)")
                                                .font(.system(size: 16, weight: .regular))
                                        }
                                    }
                                    
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("NOME")
                                                .font(.system(size: 12, weight: .medium))
                                                .gradientForeground(colors: [.pink, .purple])
                                            Text(compra.ingressos[index].proprietario)
                                                .font(.system(size: 18, weight: .regular))
                                            Text("CPF \(compra.ingressos[index].DocumentoCPF)")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("TIPO")
                                                .font(.system(size: 12, weight: .medium))
                                                .gradientForeground(colors: [.pink, .purple])
                                            Text("\(compra.ingressos[index].tipoIngresso) \(compra.ingressos[index].numeroLote)° lote")
                                                .font(.system(size: 18, weight: .regular))
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    
                                }
                                .padding()
                                .textCase(.uppercase)
                                VStack{
                                    Button(action: {
                                        // código para adicionar a wallet
                                    }, label: {
                                        
                                        HStack{
                                            Image("walletIcon")
                                            Text("Adicionar na Wallet")
                                                .foregroundColor(.black)
                                                .font(.system(size: 14, weight: .regular))
                                        }
                                        .frame(width: UIScreen.main.bounds.width * 0.4, height: 40)
                                        .background(.tertiary)
                                        .foregroundColor(.gray)
                                        .cornerRadius(12) // Raio de borda arredondado
                                        
                                    })
                                    Image(uiImage: generateQRCode(from: TicketInfo(eventoId: compra.eventoId, compraId: compra.id ?? "", dataEvento: compra.dataEvento, ingressoId: compra.ingressos[index].ingressoId ?? "", proprietarioNome: compra.ingressos[index].proprietario, documentoCPF: compra.ingressos[index].DocumentoCPF, tipoIngresso: compra.ingressos[index].tipoIngresso)))
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width * 0.4, height: 120)
                                    
                                    Text("ID \(compra.ingressos[index].ingressoId ?? "")")
                                        .font(.system(size: 10, weight: .light))
                                }
                                
                                Spacer()
                            }
                        }
                    }
            }.compositingGroup()
        }
    }
    

    func generateQRCode(from ticket: TicketInfo) -> UIImage {
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(ticket),
              let encodedString = String(data: encodedData, encoding: .utf8) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        let data = Data(encodedString.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

}


struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView(compra: Compra(eventoId: "WOZNZ4ys30ykIOUaeNKk",
                                  proprietarioIngressoId: "VYRo7ojh6lYMEmRK9amQBbSaihC3",
                                  nomeEvento: "Show the weekend",
                                  dataEvento: Date(),
                                  urlFotoCapaEvento: "https://firebasestorage.googleapis.com:443/v0/b/party-ca1c3.appspot.com/o/images%2F74AA027A-3189-46DF-9A7B-8CE1252FDFFA?alt=media&token=158299dd-a811-49fc-8fbc-c8d821ed2187",
                                  statusCompra: "aprovado",
                                  ingressos: [Ingresso(proprietario: "Rafael Gorayb",
                                                       DocumentoCPF: "36911234816",
                                                       tipoIngresso: "Entrada normal",
                                                       numeroLote: 2,
                                                       validade: true),
                                              Ingresso(proprietario: "Joao stefanel",
                                                                   DocumentoCPF: "36911234816",
                                                                   tipoIngresso: "Entrada normal",
                                                                   numeroLote: 2,
                                                                   validade: true),
                                              Ingresso(proprietario: "Rafael",
                                                                   DocumentoCPF: "36911234816",
                                                                   tipoIngresso: "Entrada normal",
                                                                   numeroLote: 2,
                                                                   validade: true)]))
    }
}
