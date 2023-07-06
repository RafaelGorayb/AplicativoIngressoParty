//
//  EventoHomeItem.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 03/07/23.
//

import SwiftUI
import FirebaseFirestore

struct EventoHomeItem: View {
    let evento: Evento
    @State private var imageLoaded = false
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: evento.urlFotoCapa)) { image in
                image.resizable()
                     .frame(width: UIScreen.main.bounds.width * 0.9, height: 180)
                     .scaledToFit()
                     .onAppear {
                         imageLoaded = true
                     }
                
            } placeholder: {
                AnimatedPlaceholder()
                   
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 180)
      
            if imageLoaded {
                EventoHomeBlurItem(evento: evento)
            }
                        
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 180)
        .cornerRadius(20)

    }
}

struct EventoHomeBlurItem: View {
    let evento: Evento
    var body: some View {
        ZStack{
            BluredRectangle()
            HStack{
                VStack{
                    Text(day(from: evento.dataInicio))
                    Text(month(from: evento.dataInicio).capitalized)
                    
                }
                .padding(.leading, 10)
                .font(.system(size: 12, weight: .medium))
                Divider()
                    .frame(width: 1.3)
                    .background(Color.white)
                
                VStack(alignment: .leading){
                    Text(evento.tituloEvento)
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                    HStack(alignment: .firstTextBaseline){
                        HStack{
                            Image(systemName: "clock")
                            Text(hourMinute(from: evento.dataInicio))
                        }
                        HStack{
                            Image(systemName: "mappin")
                            Text(evento.local)
                        }
                        Spacer()
                    }
                    .font(.system(size: 10, weight: .regular))
                }
                .padding(.leading, 10)
                Spacer()
            }
        }
        .frame(height: 60)
        .foregroundColor(.white)
    }
    
    func day(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.dateFormat = "dd"
    return formatter.string(from: date)
    }

    func month(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.dateFormat = "MMMM"
    return formatter.string(from: date)
    }

    func hourMinute(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
    }
}


struct Blur: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView
    
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<Blur>) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Blur>) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct BluredRectangle: View {
    var body: some View {
        ZStack {
            Blur(style: .systemUltraThinMaterial)
            Rectangle()
                .fill(Color.clear)
            
        }
    }
}

//struct liveCircle: View{
//    @Binding var isAnimating: Bool
//    var body: some View{
//        Circle()
//            .frame(width: 10, height: 10)
//            .foregroundColor(Color.green)
//            .opacity(isAnimating ? 1 : 0.2)
//            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
//            .onAppear {
//                self.isAnimating = true
//            }
//    }
//}

struct EventoHomeItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            Spacer()
            EventoHomeItem(evento: Evento(
                proprietarioEvento: "",
                colaboradoresEvento: [],
                tituloEvento: "Feijoada do lab",
                descricao: "Descricao do evento",
                dataInicio: Date(),
                dataFim: Date(),
                status: "Ativo",
                local: "Campinas Hall",
                ingressos: [],
                tipoBar: false,
                urlFotoCapa: "https://firebasestorage.googleapis.com/v0/b/party-ca1c3.appspot.com/o/images%2F0063A469-0DC9-4DC8-ABDE-DACFD655F733?alt=media&token=32bf6b3d-963b-4e31-952d-8771df20ce17", //
                tipoFesta: ["Funk", "Pagode"], // Array com uma String vazia
                lojaEvento: [
                    ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: ""), //
                    ItemLoja(titulo: "", preco: 0.0, alcolica: false, urlFotoItem: "", tipo: "") //
                ]
            ))                
        }
    }
}




