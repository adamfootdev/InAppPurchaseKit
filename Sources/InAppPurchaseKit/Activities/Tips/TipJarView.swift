//
//  TipJarView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI
import HapticsKit

public struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let includeNavigationStack: Bool
    private let includeDismissButton: Bool

    @State private var showingPurchasedMessage: Bool = false

    public init(
        includeNavigationStack: Bool = true,
        includeDismissButton: Bool = true,
    ) {
        self.includeNavigationStack = includeNavigationStack
        self.includeDismissButton = includeDismissButton
    }

    public var body: some View {
        Group {
            if includeNavigationStack {
                NavigationStack {
                    embeddedTipJarView
                }
            } else {
                tipJarView
            }
        }
        #if !os(tvOS)
        .accentColor(inAppPurchase.configuration.tintColor)
        #endif
        .environment(inAppPurchase)
    }

    @ViewBuilder
    private var embeddedTipJarView: some View {
        #if os(macOS)
        tipJarView
            .frame(width: 650, height: 500)
        #else
        tipJarView
        #endif
    }

    private var tipJarView: some View {
        Form {
            Section {
                VStack(spacing: headerSpacing) {
                    AppIconView(configuration: inAppPurchase.configuration)

                    Text("Thank you for using \(inAppPurchase.configuration.appName)! If youʼre enjoying the app, please consider supporting it with a tip. Anything you can spare helps me to continue building this and other indie apps!", bundle: .module)
                        #if os(tvOS)
                        .font(.caption)
                        .padding(.horizontal, 200)
                        #elseif os(watchOS)
                        .font(.footnote)
                        #else
                        .font(.callout)
                        #endif
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                #if os(tvOS)
                .padding(.bottom, 32)
                #endif
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
            }

            Section {
                ForEach(
                    Array(inAppPurchase.configuration.sortedTipJarTiers.enumerated()),
                    id: \.0
                ) { index, tier in
                    TipJarTierButton(
                        tier,
                        imageScale: 1 - (
                            CGFloat(inAppPurchase.configuration.sortedTipJarTiers.count - index) * 0.1
                        )
                    )
                }
            }

            Section {
                #if os(macOS)
                HStack {
                    Text(String(localized: "Terms of Use", bundle: .module))

                    Spacer()

                    TermsPrivacyButton(
                        String(localized: "View Terms of Use…", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )
                }

                HStack {
                    Text(String(localized: "Privacy Policy", bundle: .module))

                    Spacer()

                    TermsPrivacyButton(
                        String(localized: "View Privacy Policy…", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )
                }

                #elseif os(tvOS)
                VStack(spacing: 12) {
                    TermsPrivacyButton(
                        String(localized: "Terms of Use", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )

                    TermsPrivacyButton(
                        String(localized: "Privacy Policy", bundle: .module),
                        url: inAppPurchase.configuration.privacyPolicyURL
                    )

                    Text("Please note that these purchases do not unlock additional features.", bundle: .module)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))

                #else
                TermsPrivacyButton(
                    String(localized: "Terms of Use", bundle: .module),
                    url: inAppPurchase.configuration.termsOfUseURL
                )

                TermsPrivacyButton(
                    String(localized: "Privacy Policy", bundle: .module),
                    url: inAppPurchase.configuration.privacyPolicyURL
                )
                #endif
            } footer: {
                #if !os(tvOS)
                Text("Please note that these purchases do not unlock additional features.", bundle: .module)
                    #if os(macOS)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    #endif
                #endif
            }
        }
        .navigationTitle(String(localized: "Tip Jar", bundle: .module))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        #elseif os(macOS)
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        #endif
        .toolbar {
            #if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
            if includeDismissButton {
                doneToolbarItem
            }
            #endif
        }
        .alert(String(localized: "Thank You", bundle: .module), isPresented: $showingPurchasedMessage) {
            Button(String(localized: "Continue", bundle: .module), role: .cancel) {}
        } message: {
            Text("Thank you for the tip – it means a lot!", bundle: .module)
        }
        .onChange(of: inAppPurchase.transactionState) { _, transactionState in
            Task {
                await transactionStateUpdated(to: transactionState)
            }
        }
    }

    private var headerSpacing: CGFloat {
        #if os(tvOS)
        return 40
        #else
        return 20
        #endif
    }


    // MARK: - Update

    private func transactionStateUpdated(to transactionState: TransactionState) async {
        switch transactionState {
        case .purchased(let type):
            switch type {
            case .tipJar:
                #if os(iOS)
                HapticsKit.shared.perform(.notification(.success))
                #elseif os(watchOS)
                HapticsKit.shared.perform(.success)
                #endif

                showingPurchasedMessage = true

            default:
                return
            }
        default:
            return
        }
    }


    // MARK: - Toolbar

    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: doneButtonPlacement) {
            doneToolbarButton
                #if os(iOS) || os(macOS) || os(visionOS)
                .background {
                    Button {
                        dismiss()
                    } label: {
                        Label {
                            Text("Close", bundle: .module)
                        } icon: {
                            Image(systemName: "xmark")
                        }
                    }
                    .hidden()
                    .keyboardShortcut(.cancelAction)
                }
                #endif
        }
    }

    @ViewBuilder
    private var doneToolbarButton: some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
            Button(role: .close) {
                dismiss()
            } label: {
                #if os(macOS)
                Text("Done", bundle: .module)
                #else
                Label {
                    Text("Done", bundle: .module)
                } icon: {
                    Image(systemName: "xmark")
                }
                #endif
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif

        } else {
            Group {
                #if os(iOS)
                DismissButton {
                    dismiss()
                }
                #else
                Button {
                    dismiss()
                } label: {
                    #if os(visionOS) || os(watchOS)
                    Label {
                        Text("Done", bundle: .module)
                    } icon: {
                        Image(systemName: "xmark")
                    }
                    #else
                    Text("Done", bundle: .module)
                    #endif
                }
                #if os(visionOS)
                .buttonBorderShape(.circle)
                #endif
                #endif
            }
        }
    }

    private var doneButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .confirmationAction
        #elseif os(watchOS)
        return .cancellationAction
        #else
        return .topBarTrailing
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    TipJarView()
        .environment(inAppPurchase)
}
