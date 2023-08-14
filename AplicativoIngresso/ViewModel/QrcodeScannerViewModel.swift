//
//  QrcodeScannerViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 10/08/23.
//

import Foundation
import FirebaseFirestore

class QrcodeScannerViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    @Published var ticketInfo: TicketInfo?
    @Published var isTicketValid: Bool?
    @Published var validationMessage: String = ""
    @Published var eventoId: String = ""

    func checkTicketValidity() {
        guard let ticketInfo = ticketInfo else { return }
        let compraId = ticketInfo.compraId

        // Buscar o documento específico com base no compraId
        let docRef = db.collection("compra").document(compraId)

        docRef.getDocument { (document, error) in
            if let error = error {
                print("Erro ao buscar documento: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists,
                  let compra = try? document.data(as: Compra.self) else {
                print("Documento não encontrado.")
                return
            }

            // Verificar a validade do ingresso
            if let ingressoIndex = compra.ingressos.firstIndex(where: { $0.ingressoId == ticketInfo.ingressoId }) {
                if compra.ingressos[ingressoIndex].validade {
                    //atualizar validade no banco
                    self.invalidateTicket(compraId: compraId, ingressoIndex: ingressoIndex) {
                        self.isTicketValid = true
                        self.validationMessage = "Ingresso Válido!"
                    }
                    
                } else {
                    self.isTicketValid = false
                    self.validationMessage = "Ingresso já validado"
                }
            } else {
                self.isTicketValid = false
                self.validationMessage = "Ingresso não encontrado"
            }
        }
    }

    func invalidateTicket(compraId: String, ingressoIndex: Int, completion: @escaping () -> Void) {
        let docRef = db.collection("compra").document(compraId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let compraDocument: DocumentSnapshot
            do {
                try compraDocument = transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCompra = compraDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve compra from snapshot \(compraDocument)"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            // Supondo que o campo ingressos é um array de dicionários
            var ingressos = oldCompra["ingressos"] as! [[String: Any]]
            ingressos[ingressoIndex]["validade"] = false
            
            transaction.updateData(["ingressos": ingressos], forDocument: docRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Erro ao atualizar documento: \(error.localizedDescription)")
            } else {
                print("Documento atualizado com sucesso.")
                completion()
            }
        }
    }


    func resetState() {
        ticketInfo = nil
        isTicketValid = nil
        validationMessage = ""
    }
    
    func pertenceEvento() {
        guard let ticketInfo = ticketInfo else { return }
        // Verifique se o eventoId corresponde ao do leitor do evento
        if ticketInfo.eventoId != self.eventoId {
            self.isTicketValid = false
            self.validationMessage = "Ingresso não pertence a este evento!"
            return
        }
    }


    
}
