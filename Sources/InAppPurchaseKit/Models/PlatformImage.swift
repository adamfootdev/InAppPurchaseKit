//
//  PlatformImage.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 05/02/2024.
//

import SwiftUI

#if os(macOS)
public typealias PlatformImage = NSImage
#else
public typealias PlatformImage = UIImage
#endif
