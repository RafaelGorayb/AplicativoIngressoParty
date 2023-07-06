//
//  EditarEventoView.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 04/07/23.
//

import SwiftUI

struct EditarEventoView: View {
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var eventoVm: EventoViewModel
    @State private var showingConfirmation = false
    @State private var showingSuccess = false
    var body: some View {
        NavigationStack{
            VStack{
                addEventoListComponent().environmentObject(eventoVm)
            }
            .navigationTitle("Editar Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("Salvar", action: {
                    showingConfirmation = true
                })
                .disabled(eventoVm.isUploadingImage)
            }
            .alert(isPresented: $showingConfirmation) {
                Alert(title: Text("Confirmação"),
                      message: Text("Você deseja atualizar o evento?"),
                      primaryButton: .default(Text("Sim"), action: {
                        eventoVm.saveUpdatesEvento()
                        eventoVm.fetchEventosPropriosData(userId: userVm.uuid ?? "n/A")
                      }),
                      secondaryButton: .cancel())
            }
            .sheet(isPresented: $showingSuccess) {
                VStack {
                    Text("Evento atualizado com sucesso!")
                    Button("OK", action: { showingSuccess = false })
                }
            }
        }
        //.overlay(eventoVm.isSaving ? ProgressView() : nil) // ProgressView is displayed while the image is being uploaded
        .accentColor(.pink)
    }
}

struct EditarEventoView_Previews: PreviewProvider {
    static var previews: some View {
        //Provide an existing event for editing
        EditarEventoView().environmentObject(EventoViewModel()).environmentObject(UserViewModel())
    }
}
