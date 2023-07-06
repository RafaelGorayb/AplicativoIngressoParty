//
//  Carrinho.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 09/07/23.
//

import Foundation

struct Carrinho: Codable {
    var idEvento: String
    var ingressos: [IngressoCarrinho]
}

struct IngressoCarrinho: Codable {
    var tipo: String
    var lote: Lote
    var quantidade: Int
}

