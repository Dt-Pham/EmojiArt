//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Duong Pham on 1/11/21.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable, Hashable {
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
    
    var json: Data? {
        try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let emojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = emojiArt
        }
        else {
            return nil
        }
    }
    
    init() {}
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmoijId += 1
        emojis.append(Emoji(text, x: x, y: y, size: size, id: uniqueEmoijId))
    }
    
    mutating func removeAllEmojis() {
        emojis.removeAll()
    }
    
    private var uniqueEmoijId = 0
}
