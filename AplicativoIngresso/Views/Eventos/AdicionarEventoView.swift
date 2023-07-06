//
//  AdicionarEventoView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI

struct AdicionarEventoView: View {
    
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var eventoVm: EventoViewModel
    @Environment (\.dismiss) var dismiss
    @State private var showingConfirmation = false
    @State private var showingSuccess = false
    @State private var uploadInProgress = false
    var body: some View {
        NavigationStack{
            
            addEventoListComponent().environmentObject(eventoVm)
            .navigationTitle("Adicionar novo evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("Salvar", action: {
                    showingConfirmation = true
                })
                .disabled(eventoVm.isUploadingImage)
            }

            .alert(isPresented: $showingConfirmation) {
                Alert(title: Text("Confirmação"),
                      message: Text("Você deseja criar o evento?"),
                      primaryButton: .default(Text("Sim"), action: {
                            eventoVm.uploadImage() { result in
                                switch result {
                                case .success(let url):
                                    eventoVm.evento.proprietarioEvento = userVm.uuid ?? "N/A"
                                    eventoVm.evento.urlFotoCapa = url
                                    eventoVm.saveEvento()
                                    eventoVm.fetchEventosPropriosData(userId: userVm.uuid ?? "n/A")
                                    dismiss()
                                    showingSuccess = true
                                case .failure(let error):
                                    print("Failed to upload image: \(error)")
                                }
                            }}),
                      secondaryButton: .cancel())
            }
            .sheet(isPresented: $showingSuccess) {
                VStack {
                    Text("Evento adicionado com sucesso!")
                    Button("OK", action: { showingSuccess = false })
                }
            }
        }
        .overlay(eventoVm.isUploadingImage ? ProgressView() : nil) // ProgressView é exibida enquanto a imagem está sendo carregada
        .accentColor(.pink)
    }
}

struct addEventoListComponent: View{
    @State private var showingImagePicker = false
    @EnvironmentObject var eventoVm: EventoViewModel
    @State private var novoTipoIngresso = ""
    @State private var mostrandoLoteView = false
    @State private var indexIngressoSelecionado: Int?


    var body: some View{
        List{
            //sessao dados do evento
            Section{
                HStack{
                    Text("Dados do evento")
                        .font(.system(size: 14, weight: .regular))
                        .gradientForeground(colors: [.pink, .purple])
                    Spacer()
                }
                
                FloatingTextField(placeholder: "Titulo do evento", text: $eventoVm.evento.tituloEvento)
                
                VStack{
                    
                    DatePicker(
                        "Data de inicio",
                        selection: $eventoVm.evento.dataInicio,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    DatePicker(
                        "Data de fim",
                        selection: $eventoVm.evento.dataFim,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.gray)
                
                FloatingTextField(placeholder: "Local", text: $eventoVm.evento.local)
                FloatingTextEditor(placeholder: "Descricao", text: $eventoVm.evento.descricao)
                Toggle(isOn: $eventoVm.evento.tipoBar) {
                    Text("É open bar?")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.gray)
                }
                
                VStack (alignment: .leading) {
                    Text("Selecione o tipo de Evento")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.gray)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 20) {
                        ForEach(eventoVm.musicas, id: \.self) { musica in
                            Text(musica)
                                .font(.system(size: 16))
                                .frame(width: 80, height: 50)
                                .background(eventoVm.evento.tipoFesta.contains(musica) ? Color.pink : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .onTapGesture {
                                    if let index = eventoVm.evento.tipoFesta.firstIndex(of: musica) {
                                        // Se a string já estiver selecionada, ela será removida
                                        eventoVm.evento.tipoFesta.remove(at: index)
                                    } else {
                                        // Se a string não estiver selecionada, ela será adicionada
                                        eventoVm.evento.tipoFesta.append(musica)
                                    }
                                }
                        }
                    }
                }
                
            }.listRowSeparator(.hidden)
            
            
            //Secao dos ingressos
            Section{
                HStack {
                    Text("Ingresso")
                        .font(.system(size: 14, weight: .regular))
                        .gradientForeground(colors: [.pink, .purple])
                    Spacer()
                }
                
                
                
                FloatingTextField(placeholder: "Novo tipo de ingresso", text: $novoTipoIngresso)
                    .listRowSeparator(.hidden)
                HStack{
                    Button("Adicionar") {
                        eventoVm.loteInicial = Lote(numerolote: 1, disponibilidade: false, preco: 0, qtdDisponivel: 0, qtdVendida: 0)
                        eventoVm.novoIngresso = TipoIngresso(tipo: novoTipoIngresso, disponibilidade: false, lote: [eventoVm.loteInicial])
                        eventoVm.evento.ingressos.append(eventoVm.novoIngresso)
                        novoTipoIngresso = "" // limpa o TextField
                    }
                    .listRowSeparator(.hidden)
                    .frame(width: 100, height: 40)
                    .background(RadialGradient(colors: [.rosa1, .roxo1], center: .bottomLeading, startRadius: 0, endRadius: 150))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 12)
                    Spacer()
                }
                
                ForEach(eventoVm.evento.ingressos.indices, id: \.self) { index in
                    VStack{
                        HStack {
                            VStack{
                                Image(systemName: eventoVm.evento.ingressos[index].disponibilidade ? "checkmark.circle" : "xmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(eventoVm.evento.ingressos[index].disponibilidade ? "Disponível" : "Indisponivel").font(.system(size: 8))
                            }
                            Text(eventoVm.evento.ingressos[index].tipo)
                            Spacer()
                            Button("Editar") {
                                indexIngressoSelecionado = index
                                eventoVm.novoIngresso = eventoVm.evento.ingressos[index]
                                mostrandoLoteView = true
                                
                            }
                            
                        }.swipeActions{
                            Button(role: .destructive) {
                                let ingresso = eventoVm.evento.ingressos[index]
                                // Verifica se a quantidade vendida de qualquer lote é diferente de zero
                                let quantidadeVendida = ingresso.lote.reduce(0) { $0 + $1.qtdVendida }
                                if quantidadeVendida == 0 {
                                    eventoVm.evento.ingressos.remove(at: index)
                                }
                            } label: {
                                Label("Remover", systemImage: "trash.fill")
                            }
                            .tint(.red)
                            
                        }
                        
                        Divider()
                    }
                    .sheet(isPresented: $mostrandoLoteView, onDismiss: {
                        if let index = indexIngressoSelecionado {
                            eventoVm.evento.ingressos[index] = eventoVm.novoIngresso
                            indexIngressoSelecionado = nil
                            eventoVm.novoIngresso = TipoIngresso(tipo: "", disponibilidade: false, lote: []) // Reseta o novoIngresso
                        }
                    }) {
                        LoteView().environmentObject(eventoVm).navigationTitle("Lotes").navigationBarTitleDisplayMode(.inline)
                    }
                    .listRowSeparator(.hidden)
                }
                
                .padding(.top)
            }
               
            //sessao para upload da foto
            Section{
                HStack{
                    Text("Foto de capa")
                        .font(.system(size: 14, weight: .regular))
                        .gradientForeground(colors: [.pink, .purple])
                    Spacer()
                }
                
                Button(action: {
                    showingImagePicker = true
                }, label: {
                    ZStack{
                        if let selectedImage = eventoVm.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "camera")
                        }
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 0.5)
                    }
                    .frame(height: 150)
                })
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $eventoVm.selectedImage, sourceType: .photoLibrary) {
                        //eventoVm.uploadImage()
                    }
                }
                FloatingTextField(placeholder: "link", text: $eventoVm.evento.urlFotoCapa)
            }
            .padding(.top)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
      




struct AdicionarEventoView_Previews: PreviewProvider {
    static var previews: some View {
        AdicionarEventoView().environmentObject(EventoViewModel())
            .environmentObject(UserViewModel())
           
    }
}

struct LoteView: View {
    @EnvironmentObject var eventoVm: EventoViewModel
    @State private var mostrandoFormularioLote = false
    @State private var indexLoteSelecionado: Int?

    var body: some View {
        VStack {
            List {
                Toggle(isOn: $eventoVm.novoIngresso.disponibilidade) {
                    Text("Disponibilidade do ingresso")
                }
                ForEach(eventoVm.novoIngresso.lote.indices, id: \.self) { index in
                    VStack{
                        HStack{
                            Text( "Lote: ")
                            Text("\(eventoVm.novoIngresso.lote[index].numerolote)")
                            Spacer()
                        }
                        .font(.system(size: 18, weight: .bold))
                        .gradientForeground(colors: [.rosa1,.roxo1])
                        HStack{
                            VStack{
                                Text("Disponibilidade").font(.system(size: 10, weight: .medium))
                                Image(systemName: eventoVm.novoIngresso.lote[index].disponibilidade ? "checkmark.square" :"square" )
                                    .foregroundColor(eventoVm.novoIngresso.lote[index].disponibilidade ? .green : .gray)
                            }
                            .onTapGesture {
                                eventoVm.novoIngresso.lote[index].disponibilidade.toggle()
                            }
                            VStack {
                                HStack{
                                    VStack{
                                        Text("Preço").font(.system(size: 10, weight: .bold))
                                        Text("\(eventoVm.novoIngresso.lote[index].preco.formatted(.currency(code: "BRL")))")
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                    Spacer()
                                    
                                    VStack{
                                        Text("Disponivel").font(.system(size: 10, weight: .bold))
                                        Text("\(eventoVm.novoIngresso.lote[index].qtdDisponivel)")
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack{
                                        Text("Vendido").font(.system(size: 10, weight: .bold))
                                        Text("\(eventoVm.novoIngresso.lote[index].qtdVendida)")
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                    Spacer()
                                }
                                .padding(.top,10)
                            }
                            Spacer()
                            Button("Editar") {
                                eventoVm.loteInicial = eventoVm.novoIngresso.lote[index]
                                indexLoteSelecionado = index
                                mostrandoFormularioLote = true
                            }
                        }
                    }.swipeActions {
                        Button(role: .destructive) {
                                //Código para remover lote se qtd vendida for igual a zero
                            if eventoVm.novoIngresso.lote[index].qtdVendida == 0 {
                                eventoVm.novoIngresso.lote.remove(at: index)
                                
                                // Reorganizar números dos lotes
                                for i in index..<eventoVm.novoIngresso.lote.count {
                                    eventoVm.novoIngresso.lote[i].numerolote -= 1
                                }
                            }
                        } label: {
                            Label("Remover", systemImage: "trash.fill")
                        }
                        .tint(.red)
                        .disabled(eventoVm.novoIngresso.lote[index].qtdVendida > 0)
                    }
                   
                    
                }
                .padding()
                Button("Adicionar novo lote") {
                    let novoNumeroLote = eventoVm.novoIngresso.lote.isEmpty ? 1 : (eventoVm.novoIngresso.lote.last?.numerolote ?? 1) + 1
                                  eventoVm.novoIngresso.lote.append(Lote(numerolote: novoNumeroLote, disponibilidade: false, preco: 0, qtdDisponivel: 0, qtdVendida: 0)) // Adiciona um novo lote
                }.buttonStyle(CustomButtonStyle())
                
            }.listStyle(.plain)
            
            .sheet(isPresented: $mostrandoFormularioLote, onDismiss: {
                if let index = indexLoteSelecionado {
                    eventoVm.novoIngresso.lote[index] = eventoVm.loteInicial // Atualiza o lote selecionado
                } else {
                    eventoVm.novoIngresso.lote.append(eventoVm.loteInicial) // Adiciona um novo lote
                }
                eventoVm.loteInicial = Lote(numerolote: 1, disponibilidade: false, preco: 0, qtdDisponivel: 0, qtdVendida: 0) // Reseta o novo lote
                indexLoteSelecionado = nil // Reseta o índice do lote selecionado
            }) {
                Form {
                    Toggle(isOn: $eventoVm.loteInicial.disponibilidade) {
                        Text("Disponibilidade")
                    }
                    FloatingDoubleTextField(placeholder: "Preco", value: $eventoVm.loteInicial.preco)
                    FloatingIntTextField(placeholder: "Quantidade Disponível:", value: $eventoVm.loteInicial.qtdDisponivel)
                    FloatingIntTextField(placeholder: "Quantidade Vendida:", value: $eventoVm.loteInicial.qtdVendida)
                        .disabled(true)

 
                }
            }
        }
        
    }
}



      
