//
//  Compra.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 30/07/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Compra: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var eventoId: String
    var proprietarioIngressoId: String
    var nomeEvento: String
    var dataEvento: Date
    var urlFotoCapaEvento: String
    var statusCompra: String
    var ingressos: [Ingresso]
}

struct Ingresso: Codable{
    var ingressoId: String? = UUID().uuidString
    var proprietario: String
    var DocumentoCPF: String
    var tipoIngresso: String
    var numeroLote: Int
    var validade: Bool
}
