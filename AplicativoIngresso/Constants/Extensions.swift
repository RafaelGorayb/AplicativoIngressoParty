//
//  PaletaCores.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 07/07/23.
//

import Foundation

import SwiftUI

extension Color {
    static let rosa1 = Color(red: 231/255, green: 64/255, blue: 94/255)
    static let roxo1 = Color(red: 142/255, green: 26/255, blue: 103/255)
    static let fundoHomeItem = Color(red: 217/255, green: 217/255, blue: 217/255)
    static let verde1 = Color(red: 44/255, green: 152/255, blue: 42/255)
    
    func getColorForSituation(_ situation: String) -> Color {
        switch situation {
        case "Em andamento":
            return Color.green
        case "Dia do evento!":
            return Color.rosa1
        case "Encerrado":
            return Color.gray
        default:
            return Color.black
        }
    }
    
}

extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR") // Português do Brasil
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMMyyyy")
        return dateFormatter.string(from: self)
    }

    func formatTime() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "pt_BR") // Português do Brasil
        timeFormatter.setLocalizedDateFormatFromTemplate("HHmm")
        return timeFormatter.string(from: self)
    }
    
    func formattedAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy 'às' HH:mm"
        return dateFormatter.string(from: self)
    }
    
}
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom).combined(with: .slide)
        let removal = AnyTransition.move(edge: .top).combined(with: .slide)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}


extension View {
    func customConfirmDialog<A: View>(isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> A) -> some View {
        return self.modifier(MyCustomModifier(isPresented: isPresented, actions: actions))
    }
    
    func checkEventStatus(start: Date, end: Date) -> String {
        let calendar = Calendar.current

        let now = Date()

        if calendar.isDate(now, inSameDayAs:start) && now < start {
            return "Dia do evento!"
        } else if now < start {
            let startDay = calendar.startOfDay(for: start)
            let nowDay = calendar.startOfDay(for: now)
            let components = calendar.dateComponents([.day], from: nowDay, to: startDay)
            let dayCount = components.day ?? 0

            return "Faltam \(dayCount) dias para iniciar!"
        } else if (now >= start && now <= end) {
            return "Em andamento"
        } else if now > end {
            return "Encerrado"
        } else {
            return "Data não reconhecida"
        }
    }
    
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
            .mask(self)
    }
}

func formatCPF(_ value: String) -> String {
    var output = value.filter { "0"..."9" ~= $0 }
    
    if output.count > 11 {
        output = String(output.prefix(11))
    }
    
    let parts = [
        output.prefix(3),
        output.dropFirst(3).prefix(3),
        output.dropFirst(6).prefix(3),
        output.dropFirst(9).prefix(2)
    ]
    
    return parts.enumerated().map { (index, part) in
        switch index {
        case 0...1:
            return part + (part.count == 3 ? "." : "")
        case 2:
            return part + (output.count > 9 ? "-" : "")
        case 3:
            return part
        default:
            return part
        }
    }
    .joined()
}

    
    func unformatCPF(_ value: String) -> String {
        var output = value
        
        if value.count == 15 {
            if value.dropLast(2).last == "." {
                output = String(value.dropLast(2))
            } else if value.dropLast(1).last == "-" {
                output = String(value.dropLast(1))
            }
        }
        
        return output
    }


struct MyCustomModifier<A>: ViewModifier where A: View {
    
    @Binding var isPresented: Bool
    @ViewBuilder let actions: () -> A
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.primary.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                                isPresented = false
                        }
                        .transition(.opacity)
                }
                
                if isPresented {
                    VStack {
                        GroupBox {
                            actions()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        GroupBox {
                            Button("Cancel", role: .cancel) {
                                    isPresented = false
                            }
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.title3)
                        }
                    }
                    .padding(8)
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .animation(.easeInOut, value: isPresented)
   }
}






