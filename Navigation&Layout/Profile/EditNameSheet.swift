//
// EditNameSheet.swift


import SwiftUI

struct EditNameSheet: View {
    @Binding var newName: String
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Display Name")) {
                    TextField("New name", text: $newName)
                }
            }
            .padding(.top, 8)
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        print("Save attempt with name: \(newName)")
                        onSave()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
