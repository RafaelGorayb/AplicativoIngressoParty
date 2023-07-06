//
//  Charge.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 31/07/23.
//

import Foundation

import Foundation

struct PaymentIntent: Codable {
    let id: String
    let amount: Int
    let created: TimeInterval
    let currency: String
    let status: String
    let payment_method: String
    // Adicione outros campos conforme necessário
}

