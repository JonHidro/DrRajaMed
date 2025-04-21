//
//  ProfileImageView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/21/25.
//

// ProfileImageView.swift
import SwiftUI
import PhotosUI

struct ProfileImageView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack {
            if let url = authManager.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    case .failure(_):
                        fallbackIcon
                    case .empty:
                        ProgressView()
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }

            PhotosPicker("Change Photo", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            authManager.uploadProfileImage(uiImage)
                        }
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.top, 4)
        }
    }

    var fallbackIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
    }
}
