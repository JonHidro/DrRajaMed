//
//  SubscriptionManager.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/24/25.
//

import Foundation
import StoreKit
import FirebaseAuth

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = true  // ✅ Add loading state

    // ✅ TEMP: Whitelist dev/test users
    private let exemptUIDs: [String] = ["KSf1j9r5NETHfayO0tBlsYPESwK2","hRYjRpBS5ZgzLkAkkOkZygOPW1u2"]       // <-- Replace with your real UID
    private let exemptEmails: [String] = ["jhidrogo1@yahoo.com","hidrogojon@gmail.com"]      // <-- Replace with your email

    // ✅ Add init to start subscription check immediately
    init() {
        Task {
            await checkSubscriptionStatus()
        }
    }

    func isExemptUser(uid: String?, email: String?) -> Bool {
        if let uid = uid, exemptUIDs.contains(uid) { return true }
        if let email = email, exemptEmails.contains(email) { return true }
        return false
    }

    func hasActiveSubscription() async -> Bool {
        do {
            try await AppStore.sync()

            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let entitlement):
                    if entitlement.productID == "com.drrajamed.premium.monthly",
                       entitlement.revocationDate == nil,
                       (entitlement.expirationDate ?? .distantFuture) > Date() {
                        return true
                    }
                case .unverified(_, let error):
                    print("⚠️ Unverified entitlement: \(error.localizedDescription)")
                }
            }

            return false
        } catch {
            print("❌ StoreKit check failed: \(error.localizedDescription)")
            return false
        }
    }

    func checkSubscriptionStatus() async {
        isLoading = true  // ✅ Set loading when starting check
        
        let user = Auth.auth().currentUser
        let uid = user?.uid
        let email = user?.email

        if isExemptUser(uid: uid, email: email) {
            isSubscribed = true
            isLoading = false  // ✅ Clear loading
            print("✅ Bypassing paywall (whitelisted)")
            return
        }

        isSubscribed = await hasActiveSubscription()
        isLoading = false  // ✅ Clear loading when done
        print("🔍 Subscription status: \(isSubscribed ? "Active" : "Inactive")")
    }
}
