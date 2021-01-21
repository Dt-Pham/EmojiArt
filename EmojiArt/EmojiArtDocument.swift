//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Duong Pham on 1/11/21.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    static var palette = "😁🙃😏😭😢😳😩😎😟"
    static private let untitled = "EmojiArtDocument.Untilted"
    
    @Published private var emojiArt = EmojiArt()
    @Published private(set) var backgroundImage: UIImage?
    @Published private var selectedEmojis = Set<EmojiArt.Emoji>()
    
    private var autosaveCancellable: AnyCancellable?
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
        fetchBackgroundImageData()
    }
    
    // MARK: - Access
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
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
    
    private var fetchImageCancellable: AnyCancellable?
    
    func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data)}
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
        }
    }
}

