//
//  TransferenciaViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 02/08/23.
//

import Foundation
import FirebaseFirestore

    class TransferenciaViewModel: ObservableObject {
        
        private let db = Firestore.firestore()
        @Published var ingressosSelecionados: [Ingresso] = []
        @Published var destinatarioProprietarioIngressoId = ""
        @Published var remetenteProprietarioIngressoId = ""
        @Published var fotoDestinatario = ""
        @Published var nicknameDestinatario = ""
        @Published var compra = Compra(eventoId: "", proprietarioIngressoId: "", nomeEvento: "", dataEvento: Date(), urlFotoCapaEvento: "", statusCompra: "", ingressos: [])
        
        func transferirIngressos(completion: @escaping (Bool) -> Void) {
            guard !ingressosSelecionados.isEmpty else {
                print("Nenhum ingresso selecionado para transferir.")
                completion(false)
                return
            }
            
            // Criar uma nova Compra para o destinatário
            var novaCompra = compra
            novaCompra.proprietarioIngressoId = destinatarioProprietarioIngressoId
            novaCompra.ingressos = ingressosSelecionados
            
            // Adicionar a nova Compra ao Firestore
            let novaCompraRef = db.collection("compra").document()
            do {
                try novaCompraRef.setData(from: novaCompra)
            } catch let error {
                print("Erro ao adicionar nova compra: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Remover os ingressos selecionados da Compra original
            compra.ingressos.removeAll { ingresso in
                ingressosSelecionados.contains { $0.ingressoId == ingresso.ingressoId }
            }
            
            // Atualizar a Compra original no Firestore
            guard let compraId = compra.id else {
                print("ID da compra original não encontrado.")
                completion(false)
                return
            }
            // Identificar os IDs dos ingressos selecionados
            let ingressosSelecionadosIDs = ingressosSelecionados.compactMap { $0.ingressoId }

            // Filtrar os ingressos da compra original para remover os selecionados
            let ingressosAtualizados = compra.ingressos.filter { ingresso in
                guard let ingressoId = ingresso.ingressoId else { return true }
                return !ingressosSelecionadosIDs.contains(ingressoId)
            }

            // Codificar os ingressos atualizados para o Firestore
            let ingressosAtualizadosData: [Any]
            do {
                ingressosAtualizadosData = try ingressosAtualizados.map { try Firestore.Encoder().encode($0) }
            } catch let error {
                print("Erro ao codificar ingressos: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Referência ao documento da compra original
            let compraOriginalRef = db.collection("compra").document(compraId)

            // Atualizar o campo "ingressos" com os ingressos atualizados
            compraOriginalRef.updateData([
                "ingressos": ingressosAtualizadosData
                
            ]) { error in
                if let error = error {
                    print("Erro ao atualizar compra original: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true) // Indica que a transferência foi bem-sucedida
                }
            }

            
            completion(true) // Indica que a transferência foi bem-sucedida
        }


        
    


        
        func findUser(email: String, completion: @escaping (String?, String?, String?, Error?) -> Void) {
            let db = Firestore.firestore()
            db.collection("User").whereField("email", isEqualTo: email.lowercased()).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Erro ao buscar usuário: \(error.localizedDescription)")
                    completion(nil, nil, nil, error)
                    return
                }
                
                // Assume que o email é único, então pega o primeiro documento correspondente
                if let document = querySnapshot?.documents.first {
                    let userId = document.documentID
                    let urlFotoPerfil = document.data()["urlFotoPerfil"] as? String
                    let nome = document.data()["nome"] as? String
                    print("Usuário encontrado com ID: \(userId), URL da Foto: \(urlFotoPerfil ?? "N/A"), Nome: \(nome ?? "N/A")")
                    completion(userId, urlFotoPerfil, nome, nil)
                } else {
                    print("Nenhum usuário encontrado com esse email.")
                    completion(nil, nil, nil, nil)
                }
            }
        }
    }
