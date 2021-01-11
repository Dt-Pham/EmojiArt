//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Duong Pham on 1/11/21.
//

import Foundation

struct EmojiArt {
    var backgroundURL: URL?
    var emojis: [Emoji]
    
    struct Emoji: Identifiable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        var id: Int
        
        fileprivate init(_ text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmoijId += 1
        emojis.append(Emoji(text, x: x, y: y, size: size, id: uniqueEmoijId))
    }
    
    private var uniqueEmoijId = 0
    
    
}
