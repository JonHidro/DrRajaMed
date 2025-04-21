//
//  AuthManager.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

// AuthManager.swift
import SwiftUI
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import AuthenticationServices

class AuthManager: ObservableObject {
    // MARK: – Published state
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    @Published var displayName: String = ""
    @Published var profileImageURL: URL? = nil

    var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isSignedIn = (user != nil)

                if let user = user {
                    print("✅ Auth state changed: signed in as \(user.email ?? "Unknown")")
                    self?.loadUserProfile()
                } else {
                    self?.displayName = ""
                    self?.profileImageURL = nil
                    print("🚫 Auth state changed: signed out")
                }
            }
        }
    }

    deinit {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }

    // MARK: – Email/Password Sign‑Up
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let uid = authResult?.user.uid else {
                    completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID not found."])))
                    return
                }

                let defaultName = email.components(separatedBy: "@").first ?? "User"
                Firestore.firestore().collection("users").document(uid).setData([
                    "displayName": defaultName
                ]) { error in
                    if let error = error {
                        print("❌ Firestore user profile creation failed: \(error.localizedDescription)")
                    }
                    self.displayName = defaultName
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: – Load User Profile
    func loadUserProfile() {
        guard let uid = currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    print("❌ Snapshot failed:", error?.localizedDescription ?? "Unknown error")
                    return
                }

                if let name = data["displayName"] as? String {
                    DispatchQueue.main.async {
                        self.displayName = name
                    }
                }

                if let urlString = data["profileImageURL"] as? String,
                   let url = URL(string: urlString) {
                    DispatchQueue.main.async {
                        self.profileImageURL = url
                    }
                }
            }
    }

    // MARK: – Update Display Name
    func updateDisplayName(to newName: String) {
        guard let uid = currentUser?.uid else {
            print("❌ No current user UID found")
            return
        }

        print("🔄 Attempting to update name to: \(newName) for user \(uid)")
        
        Firestore.firestore().collection("users").document(uid).updateData([
            "displayName": newName
        ]) { error in
            if let error = error {
                print("❌ Failed to update display name: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.displayName = newName
                    print("✅ Display name updated locally to '\(newName)'")
                }
                print("✅ Display name updated in Firestore to '\(newName)'")
            }
        }
    }

    // MARK: – Upload Profile Image
    func uploadProfileImage(_ image: UIImage) {
        guard let uid = currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("avatars/\(uid).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ Upload failed: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else { return }

                Firestore.firestore().collection("users").document(uid).updateData([
                    "profileImageURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("❌ Firestore image URL update failed: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.profileImageURL = downloadURL
                        }
                        print("✅ Avatar uploaded and URL saved.")
                    }
                }
            }
        }
    }

    // MARK: – Email/Password Sign‑In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: – Google Sign‑In
    func signInWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Missing Firebase clientID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Google Sign‑In Error:", error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google Sign‑In: Missing user or ID token")
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("Firebase Google Auth Error:", error.localizedDescription)
                } else {
                    print("✅ Signed in with Google")
                }
            }
        }
    }

    // MARK: – Apple Sign‑In
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, nonce: String?) {
        switch result {
        case .success(let auth):
            guard let cred = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = cred.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8),
                  let nonce = nonce else {
                print("Apple Sign‑In: Missing credentials or nonce.")
                return
            }

            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: tokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("Firebase Apple Auth Error:", error.localizedDescription)
                } else {
                    print("✅ Signed in with Apple")
                }
            }

        case .failure(let error):
            print("Apple Sign‑In Failed:", error.localizedDescription)
        }
    }

    // MARK: – Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.currentUser = nil
                self.displayName = ""
                self.profileImageURL = nil
            }
            print("👋 Signed out")
        } catch {
            print("Sign‑out failed:", error.localizedDescription)
        }
    }

    // MARK: - Password Reset
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: – Preview Helper
    static var preview: AuthManager {
        let m = AuthManager()
        if let h = m.handle {
            Auth.auth().removeStateDidChangeListener(h)
            m.handle = nil
        }
        m.isSignedIn = true
        m.displayName = "Dr. Preview"
        return m
    }
}
