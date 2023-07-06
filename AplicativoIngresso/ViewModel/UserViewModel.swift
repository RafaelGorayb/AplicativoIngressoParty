//
//  UserViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//


import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn
import SwiftUI

class UserViewModel: ObservableObject {
    // MARK: State
    @Published var user: User?
    @Published var errorString = ""
    
    // MARK: Properties
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    var uuid: String? {
        auth.currentUser?.uid
    }
    var userIsAuthenticated: Bool {
        auth.currentUser != nil
    }
    var userIsAuthenticatedAndSynced: Bool {
        user != nil && self.userIsAuthenticated
    }
    
    // MARK: Firebase Auth Functions
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                // Handle the error here
                self?.errorString = error.localizedDescription
                print("Failed to sign in with error: ", error.localizedDescription)
                return
            }
            
            // Successfully authenticated the user, now attempting to sync with Firestore
            DispatchQueue.main.async {
                self?.sync()
            }
        }
    }
    func googleSigIn(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { [unowned self] result, error in
          guard error == nil else {
              self.errorString = error?.localizedDescription ?? ""
              return
          }

          guard let googleUser = result?.user, let idToken = googleUser.idToken?.tokenString
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleUser.accessToken.tokenString)

            auth.signIn(with: credential) { [weak self] result, error in
                if let error = error {
                    // Handle the error here
                    self?.errorString = error.localizedDescription
                    print("Failed to sign in with google: ", error.localizedDescription)
                    return
                }

                // Verify if user exists in Firestore, if not, create a new one
                self?.db.collection("User").document(self?.uuid ?? "").getDocument { document, error in
                    if let document = document, document.exists {
                        // Document and user exist, just sync
                        DispatchQueue.main.async {
                            self?.sync()
                        }
                    } else {
                        // Document doesn't exist, create a new one
                        let nome = googleUser.profile?.name
                        let email = googleUser.profile?.email
                        let urlFotoPerfil = googleUser.profile?.imageURL(withDimension: 100)?.absoluteString ?? ""
                        let newUser = User(nome: nome!, dataNascimento: Date(), email: email!, cpf: "", telefone: 0, urlFotoPerfil: urlFotoPerfil)
                        DispatchQueue.main.async {
                            self?.add(newUser)
                            self?.sync()
                        }
                    }
                }
            }
        }
    }

    
    func signUp(email: String, nome: String, dataNascimento: Date, cpf: String,telefone: Int, urlFotoPerfil: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                // Handle the error here
                self?.errorString = error.localizedDescription
                print("Failed to sign up with error: ", error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self?.add(User(nome: nome, dataNascimento: dataNascimento, email: email, cpf: cpf, telefone: telefone, urlFotoPerfil: urlFotoPerfil))
                self?.sync()
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
        } catch {
            print("Error signing out the user: \(error)")
        }
    }
    
    // Firestore functions for User Data
     func sync() {
        guard userIsAuthenticated else {
            return
        }
        db.collection("User").document(self.uuid!).getDocument { (document, error) in
            guard document != nil, error == nil else {
                return
            }
            do {
                try self.user = document!.data(as: User.self)
            } catch {
                self.errorString = error.localizedDescription
                print("Sync error: \(error)")
            }
            
        }
        
    }
    
    private func add(_ user: User) {
        guard userIsAuthenticated else {
            return
        }
        do {
            let _ = try db.collection("User").document(self.uuid!).setData(from: user)
        } catch {
            print("Error adding: \(error)")
        }
    }
    
    private func update() {
        guard userIsAuthenticatedAndSynced else {
            return
        }
        do {
            let _ = try db.collection("User").document(self.uuid!).setData(from: self.user)
        } catch {
            self.errorString = error.localizedDescription
            print("Error updating: \(error)")
        }
        
        
    }
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
    
}





