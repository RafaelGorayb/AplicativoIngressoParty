//
//  EventoViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class EventoViewModel: ObservableObject {
    @Published var eventos = [Evento]()
    @Published var mappedEventos: [String] = []
    private let db = Firestore.firestore()
    @Published var errostring = ""
    @Published var selectedImage: UIImage?
    @Published var isUploadingImage = false
    @Published var isSaving = false
    @Published var itemLojaToAdd = ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: "")
    @Published var musicas = ["Funk", "Balada", "Sertanejo", "Universitário", "Barlada", "Samba", "Pop", "Rock"]
    @Published var loteInicial = Lote(numerolote: 1, disponibilidade: false, preco: 0, qtdDisponivel: 0, qtdVendida: 0)
    @Published var novoIngresso = TipoIngresso(tipo: "", disponibilidade: false, lote: [])
    @Published var evento = Evento(
        proprietarioEvento: "",
        colaboradoresEvento: [],
        tituloEvento: "",
        descricao: "",
        dataInicio: Date(),
        dataFim: Date(),
        status: "Ativo",
        local: "",
        ingressos: [],
        tipoBar: false,
        urlFotoCapa: "",
        tipoFesta: [""],
        lojaEvento: []
    )

    
    func fetchDbData() {
        db.collection("evento").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            
            self.eventos = documents.compactMap{(queryDocumentSnapshot) -> Evento? in
                return try? queryDocumentSnapshot.data(as: Evento.self)
            }
            self.eventos.sort(by: {$0.dataInicio < $1.dataInicio})
                
                                            
        }
    }
    
    func fetchEventosPropriosData(userId: String) {
        let proprietarioEventoQuery = db.collection("evento")
            .whereField("proprietarioEvento", isEqualTo: userId)

        let colaboradoresEventoQuery = db.collection("evento")
            .whereField("colaboradoresEvento", arrayContains: userId)

        // Obtem eventos onde userId é proprietário
        proprietarioEventoQuery.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            let proprietarioEventos = documents.compactMap { (queryDocumentSnapshot) -> Evento? in
                return try? queryDocumentSnapshot.data(as: Evento.self)
            }

            // Obtem eventos onde userId é colaborador
            colaboradoresEventoQuery.getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }

                let colaboradoresEventos = documents.compactMap { (queryDocumentSnapshot) -> Evento? in
                    return try? queryDocumentSnapshot.data(as: Evento.self)
                }

                // Une os dois arrays e ordena os eventos por data
                self.eventos = (proprietarioEventos + colaboradoresEventos).sorted(by: { $0.dataInicio > $1.dataInicio })
            }
        }
    }

    
    private func addEvento(_ evento: Evento) {
        do {
            let _ = try db.collection("evento").addDocument(from: evento)
            print("Evento criado com sucesso")
        } catch {
            print("Erro ao criar evento: \(error)")
        }
    }
    
    func saveEvento() {
        addEvento(evento)
    }
    
    private func updateEvento(_ evento: Evento) {
        guard let id = evento.id else {
            print("Erro: o evento não possui ID")
            return
        }
        
        do {
            try db.collection("evento").document(id).setData(from: evento, merge: true)
            print("Evento atualizado com sucesso")
        } catch {
            print("Erro ao atualizar evento: \(error)")
        }
    }
    
    func saveUpdatesEvento(){
        updateEvento(evento)
    }
    
    
    func addItemLoja(){
        evento.lojaEvento.append(itemLojaToAdd)
        itemLojaToAdd = ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: "")
    }
    
    func uploadImage(completion: @escaping (Result<String, Error>) -> Void) {
        isUploadingImage = true
        guard let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.1) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])))
            return
        }
        let storage = Storage.storage().reference()
        let imageName = UUID().uuidString
        let imagesFolder = storage.child("images/\(imageName)")

        imagesFolder.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                completion(.failure(error))
                self.isUploadingImage = false
                return
            }
            imagesFolder.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    self.isUploadingImage = false
                    return
                }
                if let url = url {
                    completion(.success(url.absoluteString))
                    self.isUploadingImage = false
                }
            }
        }
    }

    func verificarStatusUsuario(idUsuario: String) -> String {
        if idUsuario == evento.proprietarioEvento {
            return "Dono"
        } else if evento.colaboradoresEvento.contains(idUsuario) {
            return "Colaborador"
        } else {
            return "Não Participante"
        }
    }
    
    func removeLote(fromIngresso ingressoIndex: Int, at loteIndex: Int) {
            // Verifica se a quantidade vendida do lote é 0 antes de removê-lo
            if evento.ingressos[ingressoIndex].lote[loteIndex].qtdVendida == 0 {
                evento.ingressos[ingressoIndex].lote.remove(at: loteIndex)
            } else {
                print("Não é possível remover o lote, pois a quantidade vendida é diferente de 0.")
                self.errostring = "Não é possível remover o lote, pois a quantidade vendida é diferente de 0."
            }
        }

        func removeIngresso(at index: Int) {
            // Verifica se a quantidade vendida em todos os lotes do ingresso é 0 antes de removê-lo
            if evento.ingressos[index].lote.allSatisfy({ $0.qtdVendida == 0 }) {
                evento.ingressos.remove(at: index)
            } else {
                print("Não é possível remover o ingresso, pois existe pelo menos um lote com quantidade vendida diferente de 0.")
                self.errostring = "Não é possível remover o ingresso, pois existe pelo menos um lote com quantidade vendida diferente de 0."
            }
        }
        
}
