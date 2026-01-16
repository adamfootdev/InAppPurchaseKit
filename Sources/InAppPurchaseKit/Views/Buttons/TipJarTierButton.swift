//
//  TipJarTierButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI
import StoreKit
import HapticsKit

struct TipJarTierButton: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase
    
    /// The `TipJarTier` to display.
    private let tier: TipJarTier
    
    /// A `CGFloat` containing the scale at which to show the image.
    private let imageScale: CGFloat
    
    /// Creates a new `TipJarTierButton` view.
    /// - Parameters:
    ///   - tier: The `TipJarTier` to display.
    ///   - imageScale: A `CGFloat` containing the scale at which to show the image.
    init(
        _ tier: TipJarTier,
        imageScale: CGFloat = 1
    ) {
        self.tier = tier
        self.imageScale = imageScale
    }

    var body: some View {
        #if os(tvOS)
        Button {
            if let product {
                Task {
                    await inAppPurchase.purchase(product)
                }
            }
        } label: {
            LabeledContent {
                ZStack {
                    Text(verbatim: "-")
                        .foregroundStyle(Color.clear)
                        .accessibilityHidden(true)
                        .padding(.horizontal, 12)

                    if let product {
                        Text(product.displayPrice)
                    }
                }
                .font(.callout)
                .accessibilityHidden(true)
                .overlay {
                    if product == nil || inAppPurchase.transactionState == .purchasing  {
                        ProgressView()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 2)
                    }
                }

            } label: {
                Label {
                    Text(tier.title)
                        .font(.headline)
                } icon: {
                    Image(systemName: "heart.fill")
                        .imageScale(.large)
                        .foregroundStyle(.pink)
                        .scaleEffect(imageScale)
                }
            }
            .padding(.vertical)
        }
        .disabled(disableButton)
        #else
        LabeledContent {
            Button {
                #if os(iOS)
                HapticsKit.shared.perform(.impact(.soft, intensity: 0.6))
                #elseif os(watchOS)
                HapticsKit.shared.perform(.click)
                #endif

                if let product {
                    Task {
                        await inAppPurchase.purchase(product)
                    }
                }
            } label: {
                ZStack {
                    Text(verbatim: "-")
                        .foregroundStyle(Color.clear)
                        .accessibilityHidden(true)

                    if let product {
                        Text(product.displayPrice)
                    }
                }
                #if os(iOS) || os(visionOS)
                .font(.subheadline.bold())
                #else
                .font(.subheadline)
                #endif
                #if !os(watchOS)
                .padding(.horizontal, 4)
                #endif
                .accessibilityHidden(true)
            }
            #if !os(watchOS)
            .buttonStyle(.borderedProminent)
            #if !os(macOS)
            .buttonBorderShape(.capsule)
            #endif
            #endif
            #if os(iOS)
            .controlSize(.small)
            #endif
            .disabled(disableButton)
            .overlay {
                if product == nil || inAppPurchase.transactionState == .purchasing  {
                    ProgressView()
                        #if !os(watchOS)
                        .controlSize(.mini)
                        #endif
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                }
            }

        } label: {
            Label {
                Text(tier.title)
            } icon: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .scaleEffect(imageScale)
            }
        }
        #endif
    }

    private var product: Product? {
        inAppPurchase.fetchProduct(for: tier)
    }

    private var disableButton: Bool {
        if product == nil {
            return true
        } else {
            switch inAppPurchase.transactionState {
            case .pending:
                return false
            default:
                return true
            }
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    Form {
        TipJarTierButton(.small(configuration: .example))
    }
    #if os(macOS)
    .formStyle(.grouped)
    .frame(width: 500, height: 500)
    #elseif os(visionOS)
    .frame(width: 500, height: 500)
    #endif
    .environment(inAppPurchase)
}
