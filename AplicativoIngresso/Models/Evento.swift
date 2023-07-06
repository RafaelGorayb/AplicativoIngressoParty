//
//  Evento.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Evento: Codable, Identifiable{
    @DocumentID var id: String? = UUID().uuidString
    var proprietarioEvento: String
    var colaboradoresEvento: [String]
    var tituloEvento: String
    var descricao: String
    var dataInicio: Date
    var dataFim: Date
    var status: String
    var local: String
    var ingressos: [TipoIngresso]
    var tipoBar: Bool
    var urlFotoCapa: String
    var tipoFesta: [String]
    var lojaEvento: [ItemLoja]
}

struct TipoIngresso: Codable{
    var tipo: String
    var disponibilidade: Bool
    var lote: [Lote]
}

struct Lote: Codable {
    var numerolote: Int
    var disponibilidade: Bool
    var preco: Double
    var qtdDisponivel: Int
    var qtdVendida: Int
}

struct ItemLoja: Codable{
    var titulo: String
    var preco: double_t
    var alcolica: Bool
    var urlFotoItem: String
    var tipo: String
}

struct Colaborador {
    var idUser: String
    var lerQrcode: Bool
    var editarEvento: Bool
    var analiseDados: Bool
    var gerarIngresso: Bool
}

