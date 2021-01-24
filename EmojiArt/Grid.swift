//
//  Grid.swift
//  Memorize
//
//  Created by Duong Pham on 12/28/20.
//

import SwiftUI

struct Grid<Item, ID, ItemView>: View where ID: Hashable, ItemView: View {
    private var items = [Item]()
    private var viewForItem: (Item) -> ItemView
    private var id: KeyPath<Item, ID>
    
    init(_ items: [Item], id: KeyPath<Item, ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
        self.id = id
    }
    
    var body: some View {
        GeometryReader { geometry in
            let layout = GridLayout(itemCount: items.count, in: geometry.size)
            ForEach(items, id: id) { item in
                viewForItem(item)
                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                    .position(
                        layout.location(
                            ofItemAt: items.firstIndex(where: {
                                item[keyPath: id] == $0[keyPath: id]
                            })!
                        )
                    )
            }
        }
    }
}

extension Grid where Item: Identifiable, ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}
