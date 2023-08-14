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
    @Published var eventosProprios = [Evento]()
    @Published var eventosFiltrados = [Evento]()
    var currentEventos: [Evento] {
        if !eventosFiltrados.isEmpty {
            return eventosFiltrados
        }
        return eventos
    }
    @Published var mappedEventos: [String] = []
    private let db = Firestore.firestore()
    @Published var errostring = ""
    var lastDocument: DocumentSnapshot?
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
    

    func searchEventos(query: String, completion: @escaping ([Evento]) -> Void) {
        let endpoint = "\(typesenseURL)/collections/\(collectionName)/documents/search?q=\(query)&query_by=tituloEvento"

        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-TYPESENSE-API-KEY")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(data: data, encoding: .utf8) ?? "Invalid response")
                do {
                    let searchResponse = try JSONDecoder().decode(TypesenseSearchResponse.self, from: data)
                    let eventos = searchResponse.hits.map { $0.document }
                    completion(eventos)
                } catch let decodingError as DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key) in \(context)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: \(type) in \(context)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type) in \(context)")
                    default:
                        print("Decoding error: \(decodingError)")
                    }
                } catch {
                    print("Error: \(error)")
                }

            } else {
                print("No data received:", error ?? "Unknown error")
            }
        }.resume()
    }

    struct TypesenseSearchResponse: Codable {
        struct Hit: Codable {
            let document: Evento
        }
        let hits: [Hit]
    }

    
    
    func fetchDbData() {
        var query: Query = db.collection("evento").order(by: "dataInicio").limit(to: 5)
        
        // Se tivermos um lastDocument, ajustamos a query para pegar os próximos documentos
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            
            if let lastDocument = documents.last {
                self.lastDocument = lastDocument
            }
            
            let newEventos = documents.compactMap { (queryDocumentSnapshot) -> Evento? in
                return try? queryDocumentSnapshot.data(as: Evento.self)
            }
            
            // Anexando novos eventos à lista existente
            self.eventos.append(contentsOf: newEventos)
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
                self.eventosProprios = (proprietarioEventos + colaboradoresEventos).sorted(by: { $0.dataInicio > $1.dataInicio })
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
    
    func addPromoter(eventoId: String, userId: String, completion: @escaping () -> Void) {
        // Referência para o documento
        let eventoRef = db.collection("evento").document(eventoId)
        
        // Adicionar userId ao array colaboradoresEvento
        eventoRef.updateData([
            "colaboradoresEvento": FieldValue.arrayUnion([userId])
        ]) { err in
            if let err = err {
                print("Erro ao adicionar promoter: \(err)")
            } else {
                print("Promoter adicionado com sucesso!")
                completion()
            }
        }
    }
    
    func filtraEventos(genero: String) {
        if genero == "Todos" {
            eventosFiltrados.removeAll()
        } else {
            eventosFiltrados = eventos.filter { $0.tipoFesta.contains(genero) }
        }
    }
    
    func atualizarIngressosVendidos(carrinho: Carrinho, completion: @escaping (Error?) -> Void) {

        guard !carrinho.idEvento.isEmpty else {
            print("Erro: ID do evento está vazio!")
            return
        }

        let eventoRef = db.collection("evento").document(carrinho.idEvento)
        
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let eventoDocument: DocumentSnapshot
            do {
                try eventoDocument = transaction.getDocument(eventoRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let eventoData = eventoDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Documento não encontrado no Firestore."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            var ingressosAtualizados = [TipoIngresso]()
            
            if let ingressos = eventoData["ingressos"] as? [[String: Any]] {
                for ingressoData in ingressos {
                    var ingresso = TipoIngresso(data: ingressoData)
                    for itemCarrinho in carrinho.ingressos {
                        if ingresso.tipo == itemCarrinho.tipo {
                            for (index, lote) in ingresso.lote.enumerated() {
                                if lote.numerolote == itemCarrinho.lote.numerolote {
                                    ingresso.lote[index].qtdVendida += itemCarrinho.quantidade
                                }
                            }
                        }
                    }
                    ingressosAtualizados.append(ingresso)
                }
            }
            
            transaction.updateData(["ingressos": ingressosAtualizados.map { $0.toDictionary() }], forDocument: eventoRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(error)
            } else {
                print("Transaction successfully committed!")
                completion(nil)
            }
        }
    }

    
}
