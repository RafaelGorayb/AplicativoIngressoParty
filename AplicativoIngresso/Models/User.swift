//
//  User.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable{
    @DocumentID var id: String? = UUID().uuidString
    var nome: String
    var dataNascimento: Date
    var email: String
    var cpf: String
    var telefone: Int
    var urlFotoPerfil: String
    var stripeId: String?
    var stripeLink: String?

    enum CodingKeys: String, CodingKey {
        case id, nome, dataNascimento, email, cpf, telefone, urlFotoPerfil, stripeId, stripeLink
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(String.self, forKey: .id)
        nome = try values.decode(String.self, forKey: .nome)
        dataNascimento = try values.decode(Date.self, forKey: .dataNascimento)
        email = try values.decode(String.self, forKey: .email)
        cpf = try values.decode(String.self, forKey: .cpf)
        telefone = try values.decode(Int.self, forKey: .telefone)
        urlFotoPerfil = try values.decode(String.self, forKey: .urlFotoPerfil)
        
        // Trata o valor nil como uma string vazia
        stripeId = try values.decodeIfPresent(String.self, forKey: .stripeId) ?? ""
        stripeLink = try values.decodeIfPresent(String.self, forKey: .stripeLink) ?? ""
    }
    
    init(nome: String, dataNascimento: Date, email: String, cpf: String, telefone: Int, urlFotoPerfil: String, stripeId: String = "", stripeLink: String = "") {
        self.nome = nome
        self.dataNascimento = dataNascimento
        self.email = email
        self.cpf = cpf
        self.telefone = telefone
        self.urlFotoPerfil = urlFotoPerfil
        self.stripeId = stripeId
        self.stripeLink = stripeLink
    }
}


