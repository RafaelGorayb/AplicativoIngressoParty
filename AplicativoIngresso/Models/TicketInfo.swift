//
//  TicketQrcode.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 10/08/23.
//

import Foundation

struct TicketInfo: Codable {
    var eventoId: String
    var compraId: String
    var dataEvento: Date
    var ingressoId: String
    var proprietarioNome: String
    var documentoCPF: String
    var tipoIngresso: String
}
