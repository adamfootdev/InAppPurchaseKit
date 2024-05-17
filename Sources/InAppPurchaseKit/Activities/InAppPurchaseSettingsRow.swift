//
//  InAppPurchaseSettingsRow.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 05/02/2024.
//

import SwiftUI

@available(iOS 17.0, macOS 14.4, tvOS 17.0, watchOS 10.0, *)
@MainActor
public struct InAppPurchaseSettingsRow: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    @Binding private var showingPurchaseView: Bool

    public init(showingPurchaseView: Binding<Bool>) {
        _showingPurchaseView = showingPurchaseView
    }

    public var body: some View {
        if inAppPurchase.purchaseState == .purchased {
            subscribedButton
        } else {
            purchaseButton
        }
    }


    // MARK: - Subscribed Button

    private var subscribedButton: some View {
        Button {
            showingPurchaseView = true
        } label: {
            subscribedView
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .accessibilityLabel(inAppPurchase.configuration.title)
        .accessibilityValue(String(localized: "Subscribed", bundle: .module))
    }

    private var subscribedView: some View {
        #if os(watchOS)
        VStack(alignment: .leading) {
            Text(inAppPurchase.configuration.title)

            Text("Subscribed")
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }

        #else
        LabeledContent {
            Text("Subscribed", bundle: .module)
        } label: {
            #if os(macOS) || os(tvOS)
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
        #endif
    }


    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            showingPurchaseView = true
        } label: {
            purchaseView
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

    private var purchaseView: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: purchaseSpacing) {
                Text(inAppPurchase.configuration.title)
                    .font(titleFont)
                    .foregroundStyle(titleColor)

                Text(inAppPurchase.configuration.subtitle)
                    .font(subtitleFont)
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

    private var purchaseSpacing: CGFloat {
        #if os(watchOS)
        return 0
        #else
        return 4
        #endif
    }

    private var titleFont: Font {
        #if os(tvOS) || os(watchOS)
        return Font.headline.bold()
        #elseif os(visionOS)
        return Font.title3
        #else
        return Font.title3.bold()
        #endif
    }

    private var titleColor: Color {
        #if os(macOS) || os(tvOS)
        return Color.primary
        #else
        return Color.white
        #endif
    }

    private var subtitleFont: Font {
        #if os(tvOS)
        return Font.subheadline
        #elseif os(watchOS)
        return Font.footnote
        #else
        return Font.subheadline.bold()
        #endif
    }

    private var subtitleColor: Color {
        #if os(macOS) || os(tvOS)
        return Color.secondary
        #else
        return Color.white.opacity(0.7)
        #endif
    }

    private var viewButton: some View {
        Button {
            showingPurchaseView = true
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

//#Preview {
//    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//        _ = InAppPurchaseKit.configure(with: .preview)
//    }
//
//    return NavigationStack {
//        Form {
//            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//                InAppPurchaseSettingsRow(showingPurchaseView: .constant(false))
//            }
//        }
//        #if os(macOS)
//        .formStyle(.grouped)
//        #endif
//        .navigationTitle("Settings")
//    }
//}
