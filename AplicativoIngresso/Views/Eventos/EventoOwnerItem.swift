//
//  EventoOwnerItem.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 31/07/23.
//

import SwiftUI

struct EventoOwnerItem: View {
    let evento: Evento
    @State private var cargo: String = "Default"
    @State private var imageLoaded = false
    @State private var isAnimating = true
    @State private var eventStatus = ""
    @EnvironmentObject var userVm: UserViewModel

    var body: some View {
          var eventStatus = checkEventStatus(start: evento.dataInicio, end: evento.dataFim)
            HStack{
                AsyncImage(url: URL(string: evento.urlFotoCapa)) { image in
                    image.resizable()
                        .frame(width: 60, height: 60)
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .onAppear {
                            imageLoaded = true
                        }
                } placeholder: {
                    AnimatedPlaceholder()
                    
                }
                
                if imageLoaded {
                    VStack(alignment: .leading){
                        Spacer()
                        Text(evento.tituloEvento)
                            .font(.system(size: 13, weight: .medium))
                        
                        Text(evento.dataInicio.formatDate())
                            .font(.system(size: 11, weight: .light))
                        Spacer()
                        Text(cargo)
                            .frame(width: 100)
                            .background(Color.rosa1)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        Spacer()
                    }
                    Spacer()
                        Button(action:{} , label: {
                            HStack{
                                liveCircle(isAnimating: $isAnimating)
                                Text(eventStatus)
                                    .foregroundColor(getColorForSituation(eventStatus))
                                    .font(.system(size: 14, weight: .regular))
                            }
                        })
                    }
                    
                }
                .frame(height: 60)
                .onAppear {
                    eventStatus = checkEventStatus(start: evento.dataInicio, end: evento.dataFim)
                    isAnimating = eventStatus != "Encerrado"
                    cargo = verificarStatusUsuario(idUsuario: userVm.uuid ?? "n/A")
                    
                }
            }
    func getColorForSituation(_ situation: String) -> Color {
        switch situation {
        case "Em andamento":
            return Color.green
        case "Dia do evento!":
            return Color.orange
        case "Encerrado":
            return Color.gray
        default:
            return Color.black
        }
    }
    func verificarStatusUsuario(idUsuario: String) -> String {
        if idUsuario == evento.proprietarioEvento {
            return "Dono"
        } else if evento.colaboradoresEvento.contains(idUsuario) {
            return "Colaborador"
        } else {
            return "Não Participante"
        }
    }
}


struct EventoOwnerItem_Previews: PreviewProvider {
    static var previews: some View {
        EventoOwnerItem(evento: Evento(
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
        )).environmentObject(UserViewModel())
    }
}
