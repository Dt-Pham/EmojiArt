//
//  Grid.swift
//  Memorize
//
//  Created by Duong Pham on 12/28/20.
//

import SwiftUI

struct Grid<Item, ItemView>: View where Item: Identifiable, ItemView: View {
    private var items = [Item]()
    private var viewForItem: (Item) -> ItemView
    
    init(items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            let layout = GridLayout(itemCount: items.count, in: geometry.size)
            ForEach(items) { item in
                viewForItem(item)
                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                    .position(layout.location(ofItemAt: items.firstIndex(matching: item)!))
            }
        }
    }
}
