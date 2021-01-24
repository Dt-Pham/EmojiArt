//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Duong Pham on 1/21/21.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @State var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper {
                chosenPalette = document.palette(after: chosenPalette)
            } onDecrement: {
                chosenPalette = document.palette(before: chosenPalette)
            } label: {
                EmptyView()
            }
            Text(document.paletteNames[chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor, content: {
                    PaletteEditor(chosenPalette: $chosenPalette).environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                })
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    var body: some View {
        VStack {
            Text("Palette Editor").font(.headline)
            Divider()
            Text(document.paletteNames[chosenPalette] ?? "")
            Text(chosenPalette)
        }
    }
}
