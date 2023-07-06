//
//  TransferenciaViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 02/08/23.
//

import Foundation
import FirebaseFirestore

    class TransferenciaViewModel: ObservableObject {
        
        private let db = Firestore.firestore()
        @Published var destinatarioId = ""
        @Published var remetenteId = ""
        @Published var ingressoId = ""
        @Published var compraId = ""
        
    }
