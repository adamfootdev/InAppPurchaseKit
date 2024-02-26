//
//  LegacyLockedInAppPurchaseWidgetView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

struct LegacyLockedInAppPurchaseWidgetView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.widgetFamily) private var widgetFamily

    @StateObject private var inAppPurchase: LegacyInAppPurchaseKit = .shared

    private let url: URL
    private let tint: Color?

    init(learnMoreURL url: URL, tint: Color? = nil) {
        self.url = url
        self.tint = tint
    }

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular, .accessoryCorner:
            Image(systemName: "lock.fill")
                .font(.title)

        case .accessoryInline:
            Label(
                "\(inAppPurchase.configuration.title) Required",
                systemImage: "lock.fill"
            )

        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .imageScale(.large)

                Text("\(inAppPurchase.configuration.title) Required")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote.bold())
            }

        default:
            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)

                    Text("\(inAppPurchase.configuration.title) Required")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.footnote.bold())
                }

                Button {
                    openURL(url)
                } label: {
                    Text("Learn More")
                        .font(.footnote.bold())
                        .padding(.horizontal, 4)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
                .tint(tint ?? Color.accentColor)
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    LegacyLockedInAppPurchaseWidgetView(
        learnMoreURL: URL(string: "myapp://?function=subscribe")!,
        tint: nil
    )
}
#endif
