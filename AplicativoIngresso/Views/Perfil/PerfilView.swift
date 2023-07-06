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
                if userVm.userIsAuthenticatedAndSynced{
                    List{
                        Section{
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
                            Text("Nome do usuario: \(userVm.user?.nome ?? "Erro ao carregar nome")")
                            NavigationLink(destination:  CardListView(viewModel: CardListViewModel(),customerId: userVm.user?.stripeId ?? ""), label: {
                                Text("Métodos de pagamento")
                            })
                            Text("Minhas compras")
                            Text("Alterar senha")
                            Text("Termos de serviço")
                            Text("Verificação de conta")
                        }
                        
                        
                        Button("Sair", action: {
                            userVm.signOut()
                        })
                        .foregroundColor(.rosa1)
                    }
                    .listStyle(.plain)
                } else{
                    Button(action: {
                         isShowing = true
                    }, label: {
                        Text("Fazer login")
                    })
                    .sheet(isPresented: $isShowing, content: {
                        NavigationStack{
                            AuthenticationView()
                        }
                    })
                }
            }
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
