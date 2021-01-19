//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Duong Pham on 1/11/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static var palette = "😁🙃😏😭😢😳😩😎😟"
    static private let untitled = "EmojiArtDocument.Untilted"
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
            print("json = \(emojiArt.json?.utf8 ?? "nil")")
        }
    }
    @Published private(set) var backgroundImage: UIImage?
    @Published private var selectedEmojis: Set<EmojiArt.Emoji>
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        selectedEmojis = []
        fetchBackgroundImageData()
    }
    
    // MARK: - Access
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    var numberOfSelectedEmojis: Int {
        selectedEmojis.count
    }
    
    func isSelected(emoji: EmojiArt.Emoji) -> Bool {
        selectedEmojis.contains(matching: emoji)
    }
    
    
    // MARK: - Intents
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func removeAllEmojis() {
        emojiArt.removeAllEmojis()
    }
    
    func toggleEmoji(_ emoji: EmojiArt.Emoji) {
        if selectedEmojis.contains(matching: emoji) {
            selectedEmojis.remove(at: selectedEmojis.firstIndex(matching: emoji)!)
        }
        else {
            selectedEmojis.insert(emoji)
        }
    }
    
    func deselectAllEmojis() {
        selectedEmojis.removeAll()
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func moveSelectedEmojis(by offset: CGSize) {
        for emoji in selectedEmojis {
            moveEmoji(emoji, by: offset)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func scaleSelectedEmojis(by scale: CGFloat) {
        for emoji in selectedEmojis {
            scaleEmoji(emoji, by: scale)
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

