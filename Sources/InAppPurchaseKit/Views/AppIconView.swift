//
//  AppIconView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI

struct AppIconView: View {
    private let configuration: InAppPurchaseKitConfiguration

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        ZStack {
            if let displayedAppIconImage,
               appIcon?.hasAlpha == true {
                displayedAppIconImage
                    .scaledToFit()

            } else {
                Group {
                    Color.secondary.opacity(0.2)

                    if let displayedAppIconImage {
                        displayedAppIconImage
                            .scaledToFit()
                    }
                }
                #if os(iOS) || os(tvOS)
                .clipShape(RoundedRectangle(cornerRadius: appIconRadius, style: .continuous))
                #elseif os(macOS)
                .clipShape(RoundedRectangle(cornerRadius: appIconRadius, style: .continuous))
                #elseif os(visionOS) || os(watchOS)
                .clipShape(Circle())
                #endif
            }
        }
        .frame(width: size.width, height: size.height)
        .accessibilityHidden(true)
    }

    private var appIcon: PlatformImage? {
        #if os(macOS)
        return NSImage(named: configuration.imageName)
        #else
        return UIImage(named: configuration.imageName, in: .main, with: nil)
        #endif
    }

    private var displayedAppIconImage: Image? {
        if let appIcon {
            #if os(macOS)
            return Image(nsImage: appIcon).resizable()
            #else
            return Image(uiImage: appIcon).resizable()
            #endif
        } else {
            return nil
        }
    }

    private var size: CGSize {
        #if os(tvOS)
        return .init(width: 240, height: 144)
        #elseif os(watchOS)
        return .init(width: 64, height: 64)
        #else
        return .init(width: 80, height: 80)
        #endif
    }

    private var appIconRadius: CGFloat {
        #if os(iOS) || os(macOS)
        return size.height / 5
        #elseif os(tvOS)
        return size.height / 9
        #elseif os(visionOS) || os(watchOS)
        return size.height / 2
        #else
        return size.height / 5
        #endif
    }
}

#Preview {
    AppIconView(configuration: .preview)
}
