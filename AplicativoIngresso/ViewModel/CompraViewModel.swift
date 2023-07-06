//
//  IngressoViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 19/07/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import CoreImage


class CompraViewModel: ObservableObject{
    private let db = Firestore.firestore()
    @Published var compras = [Compra]()
    @Published var compra = Compra(eventoId: "",
                                   proprietarioIngressoId: "",
                                   nomeEvento: "",
                                   dataEvento: Date(),
                                   urlFotoCapaEvento: "",
                                   statusCompra: "iniciado",
                                   ingressos: [])
    
    
    func fetchComprasData(proprietarioId: String) {
        db.collection("compra").whereField("proprietarioIngressoId", isEqualTo: proprietarioId)
            .whereField("statusCompra", isEqualTo: "aprovado")
            .addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            
            self.compras = documents.compactMap{(queryDocumentSnapshot) -> Compra? in
                return try? queryDocumentSnapshot.data(as: Compra.self)
            }
            self.compras.sort(by: {$0.dataEvento < $1.dataEvento})
                
                                            
        }
    }
    

    
    func adicionarIngresso(for ingressoSelecionado: TipoIngresso, lot: Lote, quantity: Int, eventoId: String, proprietarioIngressoId: String, nomeEvento: String, dataEvento: Date, urlFotoCapaEvento: String) {
        compra.eventoId = eventoId
        compra.proprietarioIngressoId = proprietarioIngressoId
        compra.nomeEvento = nomeEvento
        compra.dataEvento = dataEvento
        compra.urlFotoCapaEvento = urlFotoCapaEvento
        compra.statusCompra = "iniciado"
        
        // Remover todos os ingressos do mesmo tipo e lote
        compra.ingressos.removeAll(where: { $0.tipoIngresso == ingressoSelecionado.tipo && $0.numeroLote == lot.numerolote })
        
        for _ in 0..<quantity {
            compra.ingressos.append(Ingresso(proprietario: "",
                                             DocumentoCPF: "",
                                             tipoIngresso: ingressoSelecionado.tipo,
                                             numeroLote: lot.numerolote,
                                             validade: true))
        }
    }
    
    //gerar o qr code a partir de uma string
    func generateQRCode(from string: String) -> CIImage? {
        let data = Data(string.utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return output
            }
        }
        return nil
    }
     //transformar o qrCode gerado em uma string base 64 pra guardar no banco
    func saveQRCodeImage(from string: String) -> String? {
        if let qrCodeCIImage = generateQRCode(from: string),
           let qrCodeCGImage = CIContext().createCGImage(qrCodeCIImage, from: qrCodeCIImage.extent),
           let data = UIImage(cgImage: qrCodeCGImage).jpegData(compressionQuality: 1.0) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //transformar a string do qrCode base 64 do banco em imagem
    func imageFrom(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func addIngresso(_ compra: Compra) {
        do {
            let _ = try db.collection("compra").addDocument(from: compra)
            print("Ingresso criado com sucesso")
        } catch {
            print("Erro ao criar ingresso: \(error.localizedDescription)")
        }
    }
    
    func saveIngresso() {
        addIngresso(compra)
    }
    
    
    func addCompra(_ compra: Compra, statusCompra: String, completion: @escaping (_ documentId: String?, _ error: Error?) -> ()) {
        var ref: DocumentReference? = nil
        
        var compraMod = compra
        compraMod.statusCompra = statusCompra
        
        do {
            ref = try db.collection("compra").addDocument(from: compraMod)
        } catch {
            print("Erro ao criar compra: \(error.localizedDescription)")
            completion(nil, error)
            return
        }

        ref?.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(document.documentID, nil)
            } else if let error = error {
                print("Erro ao obter documento da compra: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    func updateIngresso(compraId: String, ingressoId: String, novoCPF: String, novoProprietarioIngressoId: String, completion: @escaping (Bool) -> Void) {
        // Referência ao Firestore
        let db = Firestore.firestore()

        // Referência ao documento específico da compra
        let documentRef = db.collection("compra").document(compraId)

        // Recuperar o documento
        documentRef.getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, var compra = try? document.data(as: Compra.self) else {
                print("Erro ao recuperar a compra: \(error!.localizedDescription)")
                completion(false)
                return
            }

            // Encontrar o ingresso e atualizar os valores
            if let index = compra.ingressos.firstIndex(where: { $0.ingressoId == ingressoId }) {
                compra.ingressos[index].DocumentoCPF = novoCPF
                compra.ingressos[index].proprietario = novoProprietarioIngressoId
            } else {
                print("Ingresso não encontrado")
                completion(false)
                return
            }

            // Atualizar o documento com o objeto modificado
            do {
                try documentRef.setData(from: compra)
                print("Atualizado com sucesso")
                completion(true)
            } catch {
                print("Erro ao atualizar o documento: \(error)")
                completion(false)
            }
        }
    }



}
