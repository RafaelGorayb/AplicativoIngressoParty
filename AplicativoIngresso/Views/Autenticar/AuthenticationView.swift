//
//  SwiftUIView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseAuth

struct AuthenticationView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                SignInView()
            }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var userVm: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        HStack {
            Text("Login")
                .gradientForeground(colors: [.rosa1,.roxo1])
                .font(.system(size: 28, weight: .bold))
                .padding(.leading)
            Spacer()
        }
        VStack{
           
            Spacer()

                FloatingTextField(placeholder: "Email", text: $email).keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                SecureFloatingTextField(placeholder: "senha", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                HStack{
                    NavigationLink(destination: SignUpView().environmentObject(userVm), label: {
                        Text("Cadastre-se")
                            .underline()
                    })
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Esqueci a senha.")
                            .underline()
                    })
                }
            if userVm.errorString != ""{
                Text(userVm.errorString)
                    .foregroundColor(.red)
            }
            
                Button(action: {
                    userVm.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                }
                .buttonStyle(CustomButtonStyle())
                .padding(.top)
            
            Button(action: {
                userVm.googleSigIn()
            }, label: {
                HStack{
                    Image("googleIcon")
                    Text("Entrar com o google")
                }
            }).buttonStyle(GoogleButton())
            
            Spacer()
        }
        .padding(30)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.black)
        .onAppear{
            userVm.errorString = ""
        }
                
    }
}

struct SignUpView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var email: String = ""
    @State private var nome: String = ""
    @State private var cpf: String = ""
    @State private var telefone: Int = 0
    @State private var password: String = ""
    @State private var urlFotoPerfil: String = ""
    @State private var dataNascimento = Date()

    
    var body: some View {
        HStack {
            Text("Criar conta")
                .gradientForeground(colors: [.rosa1,.roxo1])
                .font(.system(size: 28, weight: .bold))
                .padding(.leading)
            Spacer()
        }
        VStack {
            Spacer()
            VStack{
                FloatingTextField(placeholder: "Nome", text: $nome)
                FloatingTextField(placeholder: "CPF", text: $cpf).keyboardType(.numberPad)
                FloatingTextField(placeholder: "Email", text: $email).keyboardType(.emailAddress)
                //            DatePicker(
                //                "Start Date",
                //                 selection: $dataNascimento,
                //                 in: dateRange,
                //                 displayedComponents: [.date, .hourAndMinute]
                //            )
                DatePicker(
                    "Data de nascimento",
                    selection: $dataNascimento,
                    displayedComponents: [.date]
                )
                FloatingIntTextField(placeholder: "Telefone", value: $telefone).keyboardType(.phonePad)
                SecureFloatingTextField(placeholder: "Senha", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button(action: {
                    user.signUp(email: email, nome: nome, dataNascimento: dataNascimento, cpf: cpf, telefone: telefone, urlFotoPerfil: urlFotoPerfil, password: password)
                }) {
                    Text("Cadastrar")
                }
                .buttonStyle(CustomButtonStyle())
                .padding(.top, 40)
                
                if user.errorString != ""{
                    Text(user.errorString)
                        .foregroundColor(.red)
                }
            }
            .padding()
            Spacer()
        }
        .onAppear{
            user.errorString = ""
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}


