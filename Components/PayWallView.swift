//
//  PayWallView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/24/25.
//

import SwiftUI
import StoreKit

// MARK: – Plan Model
struct Plan: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let badgeText: String?
}

// MARK: – Plan Row (wider, subtitle wraps)
struct PlanRow: View {
    let plan: Plan
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title)
                .foregroundColor(isSelected ? .teal : .white.opacity(0.6))

            VStack(alignment: .leading, spacing: 6) {
                Text(plan.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(plan.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if let badge = plan.badgeText {
                Text(badge)
                    .font(.caption2).bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.teal.opacity(0.25) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.teal : Color.white.opacity(0.3), lineWidth: 1.5)
        )
    }
}

// MARK: – Paywall View
struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State private var selectedPlanID: String = "annual"

    private let features = [
        "Enjoy 3 days free!",
        "Earn CME credits",
        "Vast library of complex cases",
        "Q&A forum with experts",
        "Decades of experience"
    ]

    private let plans = [
        Plan(id: "annual",
             title: "Annual",
             subtitle: "First 3 days free, then $99/yr.",
             badgeText: "67% OFF"),
        Plan(id: "monthly",
             title: "Monthly",
             subtitle: "First 3 days free, then $19.99/mo.",
             badgeText: nil)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header Image
            ZStack(alignment: .topLeading) {
                Image("hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160, alignment: .bottom)
                    .clipped()
                    .ignoresSafeArea(edges: .top)

                Button {
                    // Sign the user out and reset navigation to show SignInView
                    authManager.signOut()
                    navigationManager.goToRoot()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.top, 50)
                .padding(.leading, 16)
            }

            // Gradient & Content
            VStack(spacing: 24) {
                // Headline (two lines)
                Text("Join Dr RajaLabs\nLearn From The Best")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)

                // Features
                VStack(spacing: 16) {
                    ForEach(features, id: \.self) { feature in
                        HStack {
                            Text(feature)
                                .foregroundColor(.white)
                                .font(.body)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // Plans (wider cards)
                VStack(spacing: 16) {
                    ForEach(plans) { plan in
                        PlanRow(plan: plan, isSelected: plan.id == selectedPlanID)
                            .onTapGesture { selectedPlanID = plan.id }
                    }
                }

                // Purchase Error
                if let error = purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // Buy Button
                Button {
                    Task { await purchaseSubscription() }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    } else {
                        Text("Start 3 Day Free Trial")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                }
                .background(Color.teal)
                .foregroundColor(.white)
                .cornerRadius(28)
                .padding(.horizontal, 16)

                // Cancel anytime
                Text("Cancel anytime")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))

                // Footer Links
                HStack(spacing: 12) {
                    Button("Restore purchases") { Task { await restorePurchases() } }
                    Circle().frame(width: 4, height: 4)
                        .foregroundColor(.white.opacity(0.6))
                    Button("Terms") { /* ... */ }
                    Circle().frame(width: 4, height: 4)
                        .foregroundColor(.white.opacity(0.6))
                    Button("Privacy policy") { /* ... */ }
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 10/255, green: 14/255, blue: 48/255),
                        Color.teal
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // ← lift all the content up by 80 points:
            .offset(y: -30)
            .padding(.bottom, -180)

        }
        .edgesIgnoringSafeArea(.top)
    }
    

    // MARK: – Purchase Logic
    func purchaseSubscription() async {
        isPurchasing = true
        purchaseError = nil
        do {
            let products = try await Product.products(for: [
                "com.drrajamed.premium.annual",
                "com.drrajamed.premium.monthly"
            ])
            guard let chosen = products.first(where: { $0.id.contains(selectedPlanID) }) else {
                purchaseError = "Product not found."
                isPurchasing = false
                return
            }
            let result = try await chosen.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    await subscriptionManager.checkSubscriptionStatus()
                case .unverified(_, let err):
                    purchaseError = "Unverified: \(err.localizedDescription)"
                }
            case .pending:
                purchaseError = "Pending…"
            case .userCancelled:
                break
            default: break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await subscriptionManager.checkSubscriptionStatus()
        } catch {
            purchaseError = "Restore failed."
        }
    }
}

// MARK: – Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(MockSubscriptionManager())
            .environmentObject(AuthManager())
            .environmentObject(NavigationManager())
            .preferredColorScheme(.dark)
    }

    class MockSubscriptionManager: SubscriptionManager {
        override func checkSubscriptionStatus() async { }
    }
}
