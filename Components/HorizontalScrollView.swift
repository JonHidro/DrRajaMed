//
//  HorizontalScrollView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct HorizontalScrollView<Item: Identifiable, Content: View>: View {
    var items: [Item]
    var cardWidth: CGFloat = 180
    var spacing: CGFloat = 15
    var content: (Item) -> Content

    @State private var scrollOffset: CGFloat = 0
    @State private var activeIndex: Int = 0

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            content(item)
                                .frame(width: cardWidth)
                                .id(index)
                                .padding(.leading, index == 0 ? 12 : 0)
                        }
                    }
                    .padding(.trailing, 16)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let offsetX = value.translation.width
                                let threshold = cardWidth / 2
                                if offsetX < -threshold {
                                    activeIndex = min(activeIndex + 1, items.count - 1)
                                } else if offsetX > threshold {
                                    activeIndex = max(activeIndex - 1, 0)
                                }
                                withAnimation(.easeOut) {
                                    proxy.scrollTo(activeIndex, anchor: .leading)
                                }
                            }
                    )
                }
            }
        }
        .frame(height: 230) // Adjust height as needed
    }
}
