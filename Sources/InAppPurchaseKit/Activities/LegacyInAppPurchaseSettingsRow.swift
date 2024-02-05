//
//  LegacyInAppPurchaseSettingsRow.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 05/02/2024.
//

import SwiftUI

public struct LegacyInAppPurchaseSettingsRow: View {
    @StateObject private var inAppPurchase: LegacyInAppPurchaseKit = .shared

    @State private var showingPurchaseSheet: Bool = false

    public init() {}

    public var body: some View {
        Group {
            if inAppPurchase.purchaseState == .purchased {
                subscribedButton
            } else {
                purchaseButton
            }
        }
        .sheet(isPresented: $showingPurchaseSheet) {
            LegacyInAppPurchaseView()
        }
    }


    // MARK: - Subscribed Button

    private var subscribedButton: some View {
        Button {
            showingPurchaseSheet.toggle()
        } label: {
            LabeledContent {
                Text("Subscribed", bundle: .module)
            } label: {
                #if os(macOS)
                Text(inAppPurchase.configuration.title)
                    .foregroundStyle(Color.primary)

                #else
                Label {
                    Text(inAppPurchase.configuration.title)
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: inAppPurchase.configuration.systemImage)
                }
                #endif
            }
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .accessibilityLabel(inAppPurchase.configuration.title)
        .accessibilityValue(String(localized: "Subscribed", bundle: .module))
    }


    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            showingPurchaseSheet.toggle()
        } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(inAppPurchase.configuration.title)
                        .font(titleFont)
                        .foregroundStyle(titleColor)

                    Text(inAppPurchase.configuration.subtitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(subtitleColor)
                }
                .minimumScaleFactor(0.6)

                #if os(iOS) || os(macOS) || os(visionOS)
                Spacer()
                viewButton
                #endif
            }
            .padding(.vertical, 8)
        }
        #if os(iOS) || os(macOS)
        .buttonStyle(.plain)
        #endif
        #if os(iOS) || os(visionOS)
        .listRowBackground(purchasedBackground)
        #elseif os(watchOS)
        .listItemTint(.accentColor)
        #endif
        .accessibilityLabel(inAppPurchase.configuration.title)
    }

    private var titleFont: Font {
        #if os(visionOS)
        return Font.title3
        #else
        return Font.title3.bold()
        #endif
    }

    private var titleColor: Color {
        #if os(macOS)
        return Color.primary
        #else
        return Color.white
        #endif
    }

    private var subtitleColor: Color {
        #if os(macOS)
        return Color.secondary
        #else
        return Color.white.opacity(0.7)
        #endif
    }

    private var viewButton: some View {
        Button {
            showingPurchaseSheet.toggle()
        } label: {
            #if os(macOS)
            Text("View…")

            #else
            Text("View")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 8)
            #endif
        }
        #if os(iOS) || os(visionOS)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.small)
        .tint(.white)
        #elseif os(macOS)
        .buttonStyle(.bordered)
        #endif
    }

    private var purchasedBackground: some View {
        #if os(visionOS)
        ZStack {
            Rectangle()
                .fill(.thickMaterial)

            Rectangle()
                .fill(Color.accentColor.gradient.opacity(0.7))
        }
        #else
        Rectangle()
            .fill(Color.accentColor.gradient)
        #endif
    }
}

#Preview {
    LegacyInAppPurchaseKit.configure(with: .preview)

    return NavigationStack {
        Form {
            LegacyInAppPurchaseSettingsRow()
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
    }
}
