//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Duong Pham on 1/23/21.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(
                        destination: EmojiArtDocumentView(document: document).navigationBarTitle(store.name(for: document))) {
                        EditableText(store.name(for: document), isEditing: editMode.isEditing) { name in
                            store.setName(name, for: document)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map {store.documents[$0]}.forEach { document in
                        store.removeDocument(document)
                    }
                }
            }
            .navigationTitle(store.name)
            .navigationBarItems(
                leading: Button(action: {store.addDocument()}, label: {Image(systemName:"plus")}),
                trailing: EditButton()
            )
            .environment(\.editMode, $editMode)
        }
    }
}
