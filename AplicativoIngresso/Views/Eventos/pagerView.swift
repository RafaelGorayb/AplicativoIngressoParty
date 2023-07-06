//
//  pagerView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 01/08/23.
//

import SwiftUI
import SwiftUIPager

struct EmbeddedExampleView: View {
    @StateObject var page1: Page = .first()
    let compra: Compra
    
    var body: some View {
        NavigationStack {
            
            GeometryReader { proxy in
                let scale = getScale(proxy: proxy)
                        Pager(page: self.page1,
                              data: compra.ingressos.indices,
                              id: \.self) { index in
                            TicketDetailsView(compra: compra, index: index)
                                .offset(y: -200)
                            
                        }
                        .interactive(rotation: true)
                        .interactive(scale: 0.7)
                        .interactive(opacity: 0.5)
                        .itemSpacing(20)
                        .itemAspectRatio(0.8, alignment: .end)
                        
                        .background(Color.gray.opacity(0.2))
                

                  
                
            }.navigationBarTitle("Ingressos", displayMode: .inline)
        }
    }
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func getScale(proxy: GeometryProxy) -> CGFloat {
        let midPoint: CGFloat = 125
         
        let viewFrame = proxy.frame(in: CoordinateSpace.global)
         
        var scale: CGFloat = 1.0
        let deltaXAnimationThreshold: CGFloat = 125
         
        let diffFromCenter = abs(midPoint - viewFrame.origin.x - deltaXAnimationThreshold / 2)
        if diffFromCenter < deltaXAnimationThreshold {
            scale = 1 + (deltaXAnimationThreshold - diffFromCenter) / 500
        }
         
        return scale
    }
}


struct EmbeddedExampleView_Previews: PreviewProvider {
    static var previews: some View {
        EmbeddedExampleView(compra: Compra(eventoId: "WOZNZ4ys30ykIOUaeNKk",
                                           proprietarioIngressoId: "VYRo7ojh6lYMEmRK9amQBbSaihC3",
                                           nomeEvento: "Show the weekend",
                                           dataEvento: Date(),
                                           urlFotoCapaEvento: "https://firebasestorage.googleapis.com:443/v0/b/party-ca1c3.appspot.com/o/images%2F74AA027A-3189-46DF-9A7B-8CE1252FDFFA?alt=media&token=158299dd-a811-49fc-8fbc-c8d821ed2187",
                                           statusCompra: "aprovado",
                                           ingressos: [Ingresso(proprietario: "Rafael Gorayb",
                                                                DocumentoCPF: "36911234816",
                                                                tipoIngresso: "Entrada normal",
                                                                numeroLote: 2,
                                                                validade: true),
                                                       Ingresso(proprietario: "Joao stefanel",
                                                                            DocumentoCPF: "36911234816",
                                                                            tipoIngresso: "Entrada normal",
                                                                            numeroLote: 2,
                                                                            validade: true),
                                                       Ingresso(proprietario: "Rafael",
                                                                            DocumentoCPF: "36911234816",
                                                                            tipoIngresso: "Entrada normal",
                                                                            numeroLote: 2,
                                                                            validade: true)]))
    }
}
