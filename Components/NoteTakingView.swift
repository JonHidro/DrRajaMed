//
//  NoteTakingView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/19/25.
//

import SwiftUI

struct NoteTakingView: View {
    let noteKey: String
    @AppStorage var noteText: String

    @Environment(\.dismiss) var dismiss

    init(noteKey: String) {
        self.noteKey = noteKey
        self._noteText = AppStorage(wrappedValue: "", noteKey)
    }

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .navigationTitle("Your Notes")
                    .navigationBarTitleDisplayMode(.inline)

                Button("Done") {
                    dismiss()
                }
                .padding()
            }
            .padding()
        }
    }
}
