//
//  Color+AppIconBorder.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 06/02/2024.
//

import SwiftUI

extension Color {
    static var appIconBorder: Color {
        #if os(iOS)
        Color(uiColor: UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
            UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1) :
            UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        })
        #elseif os(visionOS)
        Color(red: 160/255, green: 160/255, blue: 160/255)
        #elseif os(watchOS)
        Color(red: 34/255, green: 34/255, blue: 34/255)
        #else
        Color.secondary
        #endif
    }
}
