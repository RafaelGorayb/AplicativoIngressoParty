import SwiftUI
import StripePayments
import Combine

class CardListViewModel: ObservableObject {
    @Published var cards = [Card]()
    @Published var isLoading = false

    func loadCards(for customerId: String) {
        isLoading = true
        // Substitua pela URL do seu servidor
        guard let url = URL(string: "\(serverUrl)/cards") else {
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
                if let cards = try? decoder.decode([Card].self, from: data) {
                    DispatchQueue.main.async {
                        self.cards = cards
                        self.isLoading = false  // Defina como false quando terminar de carregar
                    }
                }
            }
        }.resume()
    }
    
    func deleteCard(id: String, customerId: String) {
        // Substitua pela URL do seu servidor
        guard let url = URL(string: "\(serverUrl)/delete-card?id=\(id)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = data {
                // Recarregue os cartões depois que um é deletado
                self.loadCards(for: customerId) // Substitua por um ID de cliente real
            }
        }.resume()
    }
}

struct Card: Codable, Identifiable {
    let id: String
    let last4: String
    let exp_month: Int
    let exp_year: Int
    let brand: String
}

