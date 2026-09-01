//
//  AffiliateConfig.swift
//  Affiliate
//
//  Central configuration: brand, URLs and constants.
//

import Foundation

enum AppConfig {
    // Brand
    static let appName = "Affiliate"
    static let brandName = "MyStake"
    static let tagline = "Premium affiliate companion"

    // Destinations
    static let mainSite = URL(string: "https://mystake.com")!
    static let liveContent = URL(string: "https://mystake.great-site.net/")!

    // URL checking
    static let defaultAffiliateURL = "https://mystake.com"
    static let allowedHosts: Set<String> = [
        "mystake.com",
        "www.mystake.com",
        "mystake.great-site.net"
    ]

    // Support
    static let supportEmail = "support@mystake.com"

    // Version
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
