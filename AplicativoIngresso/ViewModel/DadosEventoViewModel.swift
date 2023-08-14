//
//  DadosEventoViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 19/08/23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class DadosEventoViewModel: ObservableObject {
    private let db = Firestore.firestore()
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
    
    // Inicializador padrão
    init() {
        self.evento = Evento(
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
    }

    // Inicializador que aceita um evento específico
    init(evento: Evento) {
        self.evento = evento
    }
    
    // Retorna um lote válido com a disponibilidade `true` e o menor número
    func loteDisponivelMaisBaixo(tipoIngresso: TipoIngresso) -> Lote? {
        return tipoIngresso.lote
            .filter { $0.disponibilidade }
            .sorted { $0.numerolote < $1.numerolote }
            .first
    }

    func porcentagemVendida(lote: Lote) -> Double {
        return (Double(lote.qtdVendida) / Double(lote.qtdDisponivel)) * 100.0
    }

    
    // Função para calcular a quantidade total de ingressos vendidos
    func totalIngressosVendidos() -> Int {
        return evento.ingressos.reduce(0) { (sum, tipoIngresso) -> Int in
            sum + tipoIngresso.lote.reduce(0) { (loteSum, lote) -> Int in
                loteSum + lote.qtdVendida
            }
        }
    }
    
    func porcentagemVendidaTotal(tipoIngresso: TipoIngresso) -> Double {
        let totalIngressosTipo = tipoIngresso.lote.reduce(0) { $0 + $1.qtdDisponivel }
        let totalVendidosTipo = tipoIngresso.lote.reduce(0) { $0 + $1.qtdVendida }
        return (Double(totalVendidosTipo) / Double(totalIngressosTipo)) * 100.0
    }

}
