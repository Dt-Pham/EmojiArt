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
                    PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                })
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button {
                        isShowing = false
                    } label: {
                        Text("Done").padding()
                    }
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName) { began in
                        if !began {
                            document.renamePalette(chosenPalette, to: paletteName)
                        }
                    }
                    TextField("Add Emoji", text: $emojisToAdd) { began in
                        if !began {
                            chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    }
                }
                Section {
                    Grid(chosenPalette.map{ String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: fontSize))
                            .onTapGesture {
                                chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                            }
                    }
                    .frame(height: height)
                }
            }
        }
        .onAppear {
            paletteName = document.paletteNames[chosenPalette] ?? ""
        }
    }
    
    // MARK: - Drawing constants
    private let fontSize: CGFloat = 40
    private var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
}
