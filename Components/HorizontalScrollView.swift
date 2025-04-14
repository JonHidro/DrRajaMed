//
//  HorizontalScrollView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct HorizontalScrollView<Item: Identifiable, Content: View>: View {
    var items: [Item]
    var content: (Item) -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(items) { item in
                    content(item)
                }
            }
            .padding(.horizontal)
        }
    }
}
