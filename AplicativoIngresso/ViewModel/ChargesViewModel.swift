//
//  ChargesViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 07/08/23.
//

import Foundation

struct Charge: Codable, Identifiable {
    let id: String
    let amount: Int
    let created: Int // Timestamp
    let currency: String
    let description: String?
    let status: String
    let payment_method_details: PaymentMethodDetails

}

struct PaymentMethodDetails: Codable {
    let card: CardDetails

}

struct CardDetails: Codable {
    let brand: String
    let last4: String
}



class ChargeListViewModel: ObservableObject {
    @Published var charges = [Charge]()
    @Published var isLoading = false  // Novo
    
    func loadCharges(for customerId: String) {
        isLoading = true
        // Substitua pela URL do seu servidor
        guard let url = URL(string: "\(serverUrl)/list-charges") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["customerId": customerId]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let charges = try? decoder.decode([Charge].self, from: data) {
                    DispatchQueue.main.async {
                        self.charges = charges
                    }
                }
            } else {
                // Lidar com erro ou impressão
                print("Erro ao buscar cargas:", error?.localizedDescription ?? "Unknown error")
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }
}

