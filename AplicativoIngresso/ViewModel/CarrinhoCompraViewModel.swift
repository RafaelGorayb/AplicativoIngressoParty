//
//  CompraViewModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 14/07/23.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseStorage
import StripePaymentSheet
import Combine

struct PaymentResponse: Codable {
    let paymentId: String
    let publishableKey: String
    let paymentIntent: String
    let customer: String
    let ephemeralKey: String
    // Você pode adicionar outros campos conforme necessário
}

struct ServerResponse: Codable {
    let paymentId: String
    let publishableKey: String
    let paymentIntent: String
    let customer: String
    let ephemeralKey: String
}



class CarrinhoCompraViewModel: ObservableObject {
   
    let backendCheckoutUrl = URL(string: "\(serverUrl)/paymentIntentCreate")!  // An example backend endpoint
    @Published var paymentSheetFlowController: PaymentSheet.FlowController?
    @Published var paymentResult: PaymentSheetResult?
    @Published var carrinho = Carrinho(idEvento: "", ingressos: [])
    @Published var paymentIntentId = ""
    @Published var selecionados: [String: Int] = [:]
    @Published var paymentIntent: PaymentIntent?
    
    @Published var response: ServerResponse?
    @Published var errorMessage: String?
    var cancellables = Set<AnyCancellable>()
        
        func preparePaymentSheets(customerID: String, carrinho: Carrinho) {
            guard let url = URL(string: "\(serverUrl)/paymentIntentCreate") else {
                errorMessage = "URL inválida."
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let carrinhoData = try JSONEncoder().encode(carrinho)
                let paymentInfo: [String: Any] = ["customerID": customerID, "carrinho": String(data: carrinhoData, encoding: .utf8)!]
                let postData = try JSONSerialization.data(withJSONObject: paymentInfo, options: [])
                request.httpBody = postData
            } catch {
                errorMessage = "Falha ao codificar o carrinho e/ou o customerID: \(error)"
                return
            }
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return data
                }
                .decode(type: ServerResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = "Erro na requisição: \(error)"
                    }
                }, receiveValue: { response in
                    self.response = response
                    self.configurePaymentSheet(with: response)
                })
                .store(in: &cancellables)
        }
        
        private func configurePaymentSheet(with response: ServerResponse) {
            // Aqui, você insere a configuração do seu PaymentSheet
            // Este código é retirado da sua função original
            
            paymentIntentId = response.paymentId
            STPAPIClient.shared.publishableKey = response.publishableKey
            
            //Configuracoes paymentSheet - cores
            var appearance = PaymentSheet.Appearance()
            var configuration = PaymentSheet.Configuration()
            appearance.font.base = UIFont(name: "AvenirNext-Regular", size: UIFont.systemFontSize)!
            appearance.cornerRadius = 12
            appearance.shadow = .disabled
            appearance.borderWidth = 0.5
            appearance.colors.background = .white
            appearance.colors.primary = UIColor (.rosa1)
            appearance.colors.textSecondary = .black
            appearance.colors.componentPlaceholderText = UIColor(red: 115/255, green: 117/255, blue: 123/255, alpha: 1)
            appearance.colors.componentText = .black
            appearance.colors.componentBorder = UIColor(red: 195/255, green: 213/255, blue: 200/255, alpha: 1)
            appearance.colors.componentDivider = UIColor(red: 195/255, green: 213/255, blue: 200/255, alpha: 1)
            appearance.colors.componentBackground = .clear
            appearance.primaryButton.cornerRadius = 12
            configuration.appearance = appearance
            //Configuracoes paymentSheet
            configuration.merchantDisplayName = "Party eventos"
            configuration.style = .alwaysLight
            configuration.defaultBillingDetails.address.country = "BR"
            configuration.billingDetailsCollectionConfiguration.name = .always
            configuration.billingDetailsCollectionConfiguration.email = .automatic
            configuration.billingDetailsCollectionConfiguration.address = .full
            configuration.billingDetailsCollectionConfiguration.attachDefaultsToPaymentMethod = true
            configuration.applePay = .init(merchantId: "party eventos", merchantCountryCode: "BR")
            configuration.customer = .init(id: response.customer, ephemeralKeySecret: response.ephemeralKey)
            configuration.returnURL = "payments-example://stripe-redirect"
            configuration.allowsDelayedPaymentMethods = false

            PaymentSheet.FlowController.create(
                paymentIntentClientSecret: response.paymentIntent,
                configuration: configuration
            ) { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let paymentSheetFlowController):
                    DispatchQueue.main.async {
                        self?.paymentSheetFlowController = paymentSheetFlowController
                    }
                }
            }
        }
    

    
    
//    func preparePaymentSheet(customerID: String, carrinho: Carrinho) {
//        // MARK: Fetch the PaymentIntent and Customer information from the backend
//        var request = URLRequest(url: backendCheckoutUrl)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let carrinhoData = try JSONEncoder().encode(carrinho)
//            let paymentInfo: [String: Any] = ["customerID": customerID, "carrinho": String(data: carrinhoData, encoding: .utf8)!]
//            let postData = try JSONSerialization.data(withJSONObject: paymentInfo, options: [])
//            request.httpBody = postData
//        } catch {
//            print("Falha ao codificar o carrinho e/ou o custumerID: \(error)")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
//            guard let data = data else {
//                print("Erro ao receber dados: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            let decoder = JSONDecoder()
//            do {
//                let response = try decoder.decode(PaymentResponse.self, from: data)
//
//                self.paymentIntentId = response.paymentId
//                STPAPIClient.shared.publishableKey = response.publishableKey
//
//                // MARK: Create a PaymentSheet instance
//
//                //Configuracoes paymentSheet - cores
//                var appearance = PaymentSheet.Appearance()
//                var configuration = PaymentSheet.Configuration()
//                appearance.font.base = UIFont(name: "AvenirNext-Regular", size: UIFont.systemFontSize)!
//                appearance.cornerRadius = 12
//                appearance.shadow = .disabled
//                appearance.borderWidth = 0.5
//                appearance.colors.background = .white
//                appearance.colors.primary = UIColor (.rosa1)
//                appearance.colors.textSecondary = .black
//                appearance.colors.componentPlaceholderText = UIColor(red: 115/255, green: 117/255, blue: 123/255, alpha: 1)
//                appearance.colors.componentText = .black
//                appearance.colors.componentBorder = UIColor(red: 195/255, green: 213/255, blue: 200/255, alpha: 1)
//                appearance.colors.componentDivider = UIColor(red: 195/255, green: 213/255, blue: 200/255, alpha: 1)
//                appearance.colors.componentBackground = .clear
//                appearance.primaryButton.cornerRadius = 12
//                configuration.appearance = appearance
//                //Configuracoes paymentSheet
//                configuration.merchantDisplayName = "Party eventos"
//                configuration.style = .alwaysLight
//                configuration.defaultBillingDetails.address.country = "BR"
//                configuration.billingDetailsCollectionConfiguration.name = .always
//                configuration.billingDetailsCollectionConfiguration.email = .automatic
//                configuration.billingDetailsCollectionConfiguration.address = .full
//                configuration.billingDetailsCollectionConfiguration.attachDefaultsToPaymentMethod = true
//                configuration.applePay = .init(merchantId: "party eventos", merchantCountryCode: "BR")
//                configuration.customer = .init(id: response.customer, ephemeralKeySecret: response.ephemeralKey)
//                configuration.returnURL = "payments-example://stripe-redirect"
//                configuration.allowsDelayedPaymentMethods = false
//
//                PaymentSheet.FlowController.create(
//                                paymentIntentClientSecret: response.paymentIntent,
//                                configuration: configuration
//                            ) { [weak self] result in
//                                switch result {
//                                case .failure(let error):
//                                    print(error)
//                                case .success(let paymentSheetFlowController):
//                                    DispatchQueue.main.async {
//                                        self?.paymentSheetFlowController = paymentSheetFlowController
//                                    }
//                                }
//                            }
//
//                        } catch {
//                            print("Erro na decodificação: \(error.localizedDescription)")
//                        }
//                    }
//                    task.resume()
//                }


    func onOptionsCompletion() {
        // Tell our observer to refresh
        objectWillChange.send()
    }

    func onCompletion(result: PaymentSheetResult) {
        self.paymentResult = result

        // MARK: Demo cleanup
        if case .completed = result {
                // A PaymentIntent can't be reused after a successful payment. Prepare a new one for the demo.
                //self.paymentSheetFlowController = nil
            //redirecionar para pagina de sucesso do pagamento
            
        }
    }
    
    func cancelPaymentIntent(completion: @escaping (Result<Void, Error>) -> Void) {
        // Defina a URL do servidor
        guard let url = URL(string: "\(serverUrl)/cancelPaymentIntent") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Crie o objeto de solicitação
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Codifique os dados do body
        let bodyData = [
            "paymentIntentID": paymentIntentId
        ]
        
        do {
            let body = try JSONSerialization.data(withJSONObject: bodyData, options: [])
            request.httpBody = body
        } catch {
            completion(.failure(error))
            return
        }
        
        // Execute a solicitação
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Verifique se há algum erro
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Verifique a resposta do servidor
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Verifique se há dados e analise a resposta JSON
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                print("Status: \(jsonResponse["status"] ?? "unknown")")
                                print("Message: \(jsonResponse["message"] ?? "unknown")")
                                if jsonResponse["status"] as? String == "success" {
                                    completion(.success(()))
                                } else {
                                    let error = NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: jsonResponse)
                                    completion(.failure(error))
                                }
                            }
                        } catch {
                            let error = NSError(domain: "JSON parsing error", code: -1, userInfo: nil)
                            completion(.failure(error))
                        }
                    }
                } else {
                    let error = NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func updatePaymentIntentMetadata(documentId: String, eventoId: String) {
        // URL da rota de atualização do PaymentIntent no seu servidor
        let updatePaymentIntentUrl = URL(string: "\(serverUrl)/update-payment-intent")!

        var request = URLRequest(url: updatePaymentIntentUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Coloque o ID do documento no campo de metadata
        let metadata = ["documentId": documentId,
                        "eventoId": eventoId]

        do {
            let postData: [String: Any] = [
                "paymentIntentId": self.paymentIntentId,
                "metadata": metadata
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: postData, options: [])
        } catch {
            print("Failed to encode metadata: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error updating PaymentIntent: \(error)")
                return
            }

            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Successfully updated PaymentIntent metadata")
                    // Caso queira fazer algo com a resposta
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Response: \(json)")
                        }
                    } catch {
                        print("Failed to decode response: \(error)")
                    }
                } else {
                    print("Failed to update PaymentIntent metadata: \(httpResponse.statusCode)")
                }
            }
        }

        task.resume()
    }
    


    func getPaymentIntent(paymentId: String) {
        guard let url = URL(string: "\(serverUrl)/retrieve-payment-intent") else {
            print("Error creating URL")
            return
        }
        
        let body: [String: Any] = ["paymentIntentId": paymentId]
        do {
            let finalBody = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(PaymentIntent.self, from: data)
                        DispatchQueue.main.async {
                            self.paymentIntent = decodedResponse
                        }
                    } catch {
                        print("Error decoding JSON: \(error.localizedDescription)")
                    }
                } else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
            
        } catch {
            print("Error encoding body: \(error.localizedDescription)")
        }
    }




    func updateCart(for ingresso: TipoIngresso, lot: Lote, quantity: Int) {
         if let index = carrinho.ingressos.firstIndex(where: { $0.tipo == ingresso.tipo && $0.lote.numerolote == lot.numerolote }) {
             if quantity == 0 {
                 carrinho.ingressos.remove(at: index)
             } else {
                 carrinho.ingressos[index].quantidade = quantity
             }
         } else if quantity > 0 {
             let newIngresso = IngressoCarrinho(tipo: ingresso.tipo, lote: lot, quantidade: quantity)
             carrinho.ingressos.append(newIngresso)
         }

         selecionados["\(ingresso.tipo)-\(lot.numerolote)"] = quantity
     }
     
     var totalAmount: Double {
         carrinho.ingressos.reduce(0.0) { sum, ingresso in
             return sum + ingresso.lote.preco * Double(ingresso.quantidade)
         }
     }
     
     var totalTax: Double {
         totalAmount * 0.1
     }
     
     var totalFinalAmount: Double {
         totalAmount + totalTax
     }
 }


