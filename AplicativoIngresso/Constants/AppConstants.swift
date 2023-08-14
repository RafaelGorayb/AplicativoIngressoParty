//
//  AppConstants.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 22/07/23.
//

import Foundation

//let serverUrl = "https://light-innovative-frigate.glitch.me"
//string servidor para funcoes de pagamento
let serverUrl = "https://party-delta.vercel.app/api"

//dados do typesense
let typesenseURL = "https://search.partyeventos.com.br:443" // Altere para o URL do seu servidor Typesense
let collectionName = "evento"
let apiKey = "uoGlY6oemKSDWDU2FkqB8b3myPm4TjeOXRdqmAcPXu5FA7ao" // Altere para sua chave API do Typesense

// objeto evento teste para usar no preview
let eventoDemo = Evento(
    proprietarioEvento: "65465465",
    colaboradoresEvento: [],
    tituloEvento: "Entrosa Bixo 2023",
    descricao: "O Carnaval ainda não chegou, mas o after já tá garantido!✨ \n\nBixos e bixetes, o primeiro open bar da Morsa do ano já tem data marcada e é a maior e melhor integração com seus veteranos 💚 \n\nAnota aí no seu calendário, dia 16 de março é dia de fazer o que a gente mais gosta: beber muuuuuita breja gelada e Juquinha, e integrar com muita tinta e glitter! 🍻",
    dataInicio: Date(),
    dataFim: Date(),
    status: "Ativo",
    local: "Campinas Hall",
    ingressos: [
        TipoIngresso(tipo: "Pista", disponibilidade: true, lote: [
            Lote(numerolote: 1, disponibilidade: true, preco: 100, qtdDisponivel: 1550, qtdVendida: 890),
            Lote(numerolote: 2, disponibilidade: false, preco: 180, qtdDisponivel: 1550, qtdVendida: 0)
        ]),
        
        TipoIngresso(tipo: "Camarote", disponibilidade: true, lote: [
            Lote(numerolote: 1, disponibilidade: true, preco: 250, qtdDisponivel: 780, qtdVendida: 652)
        ])
    ],
    tipoBar: false,
    urlFotoCapa: "https://firebasestorage.googleapis.com:443/v0/b/party-ca1c3.appspot.com/o/images%2FE7F4AFE1-067B-48AE-A4B9-36652578B4A1?alt=media&token=5f55a94d-1f6a-454b-863a-9999f44c2864", //
    tipoFesta: ["Funk", "Pagode"], // Array com uma String vazia
    lojaEvento: [
        ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: ""), //
        ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: "") //
    ]
    )
