//
//  PerfilView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI
import SDWebImageSwiftUI


struct PerfilView: View {
    @EnvironmentObject var userVm: UserViewModel
    @State var isShowing = false
    var body: some View {
        NavigationStack{
            VStack {
                List{
                    if userVm.userIsAuthenticatedAndSynced{
                        Section{
                            VStack{
                                HStack{
                                    Spacer()
                                    if let imageUrl = userVm.user?.urlFotoPerfil, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                                        WebImage(url: url)
                                            .resizable()
                                            .placeholder(Image(systemName: "person.circle.fill")) // Placeholder Image
                                        // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                                            .onSuccess { image, data, cacheType in
                                                // Success
                                                // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                                            }
                                            .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                                            .placeholder(Image(systemName: "photo")) // Placeholder Image
                                            .indicator(.activity) // Activity Indicator
                                            .transition(.fade(duration: 0.5)) // Fade Transition with duration
                                            .scaledToFit()
                                            .frame(width: 100, height: 100, alignment: .center)
                                            .cornerRadius(50)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100, alignment: .center)
                                            
                                    }
                                    Spacer()
                                }
                                
                                Text( "\(userVm.user?.nome ?? "Erro ao carregar nome")")
                            }
                        }.listRowSeparator(.hidden).listRowBackground(Color.gray.opacity(0.05))
                        
                        Section{
                            
                            NavigationLink(destination:  CardListView(viewModel: CardListViewModel(),customerId: userVm.user?.stripeId ?? ""), label: {
                                HStack{
                                    Image(systemName: "creditcard.fill")
                                        .gradientForeground(colors: [.rosa1, .roxo1])
                                    Text("Métodos de pagamento")
                                }
                            })
                            NavigationLink(destination: ChargesListView(customerId: userVm.user?.stripeId ?? "").environmentObject(ChargeListViewModel()), label: {
                                HStack{
                                    Image(systemName: "bag.fill")
                                        .gradientForeground(colors: [.rosa1, .roxo1])
                                    Text("Minhas compras")
                                }
                            })
                            NavigationLink(destination: MeusEventosView().environmentObject(userVm).environmentObject(EventoViewModel()), label: {
                                HStack{
                                    Image(systemName: "ticket.fill")
                                        .gradientForeground(colors: [.rosa1, .roxo1])
                                    Text("Meus eventos")
                                }
                            })
                            HStack{
                                Image(systemName: "ellipsis.rectangle.fill")
                                    .gradientForeground(colors: [.rosa1, .roxo1])
                                Text("Alterar senha")
                            }
                            HStack{
                                Image(systemName: "questionmark.circle.fill")
                                    .gradientForeground(colors: [.rosa1, .roxo1])
                                Text("Ajuda")
                            }
                            
                        }.listRowBackground(Color.gray.opacity(0.05))
                        
                    } else{
                        HStack{
                            Spacer()
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100, alignment: .center)
                            
                            Spacer()
                        }
                    }
                    
                    Section{
                        Text("Termos de serviço")
                        Text("Ajuda")
                    }.listRowBackground(Color.gray.opacity(0.05))
                    
                    if userVm.userIsAuthenticatedAndSynced{
                        Button("Sair", action: {
                            userVm.signOut()
                        })
                        .foregroundColor(.rosa1)
                    } else{
                        Button(action: {
                            isShowing = true
                        }, label: {
                            Text("Fazer login")
                        })
                        .buttonStyle(CustomButtonStyle())
                        .sheet(isPresented: $isShowing, content: {
                            NavigationStack{
                                AuthenticationView()
                            }
                        })
                    }
                }
                    
            }
            .scrollContentBackground(.hidden)
            .background(.white)
            
            .navigationTitle("Minha conta")
            .onAppear(){
                userVm.sync()
            }
        }
    }
}

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView().environmentObject(UserViewModel())
    }
}
