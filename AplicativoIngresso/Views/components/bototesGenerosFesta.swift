//
//  bototesGenerosFesta.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 06/07/23.
//

import SwiftUI

struct bototesGenerosFesta: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(musicGenres, id: \.name) { genre in
                    VStack {
                        Button(action: {
                            print("Button \(genre.name) pressed")
                        }) {
                            VStack {
                                Image(systemName: genre.iconName)
                                    .font(.system(size: 20))
                                Text(genre.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                    }
                }
            }
            .tint(.black)
            .padding()
        }
    }
}

struct Genre {
    let name: String
    let iconName: String
}

let musicGenres = [
    Genre(name: "Todos", iconName: "balloon.2"),
    Genre(name: "Funk", iconName: "music.note"),
    Genre(name: "Balada", iconName: "music.mic"),
    Genre(name: "Rodeio", iconName: "music.house"),
    Genre(name: "Universitário", iconName: "graduationcap"),
    Genre(name: "Barlada", iconName: "music.note.list"),
    Genre(name: "Samba", iconName: "guitars"),
    Genre(name: "Pop", iconName: "headphones"),
    Genre(name: "Rock", iconName: "guitars")
]


struct bototesGenerosFesta_Previews: PreviewProvider {
    static var previews: some View {
        bototesGenerosFesta()
    }
}
