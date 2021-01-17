//
//  EmojiArtView.swift
//  EmojiArtView
//
//  Created by Duong Pham on 1/11/21.
//

import SwiftUI

struct EmojiArtView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(EmojiArtDocument.palette.map{ String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .font(Font.system(size: defaultEmojiSize))
                        .onDrag {
                            NSItemProvider(object: emoji as NSString)
                        }
                }
            }
        }
        .padding()
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .foregroundColor(.yellow)
                    .overlay(
                        OptionalImage(image: document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(animatableWithSize: zoomScale * defaultEmojiSize)
                        .position(self.position(for: emoji, in: geometry.size))
                }
            }
            .clipped()
            .gesture(panGesture())
            .gesture(zoomGesture())
            .ignoresSafeArea(edges: [.bottom, .horizontal])
            .onDrop(of: ["public.Image", "public.Text"], isTargeted: nil) { providers, location in
                var location = geometry.convert(location, from: .global)
                location = location - panOffset
                location = CGPoint(x: location.x - geometry.size.width / 2,
                                   y: location.y - geometry.size.height / 2)
                location = location / zoomScale
                return self.drop(providers: providers, at: location)
            }
        }
    }
    
    // MARK: - Zoom gestures
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        steadyStatePanOffset = .zero
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                steadyStateZoomScale *= finalGestureScale
            }
    }
    
    // MARK: - Pan gesture
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestGesturePanOffset, gesturePanOffset, transaction in
                gesturePanOffset = latestGesturePanOffset.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + finalDragGestureValue.translation / zoomScale
            }
    }
    
    // MARK: - Helper functions
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: CGFloat(emoji.x) * zoomScale + panOffset.width + size.width / 2,
                y: CGFloat(emoji.y) * zoomScale + panOffset.height + size.height / 2)
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("droped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
    
    // MARK: - Drawing constant(s)
    private let defaultEmojiSize: CGFloat = 40
}
