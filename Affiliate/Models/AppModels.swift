//
//  AppModels.swift
//  Affiliate
//
//  Shared data models used across the app.
//

import Foundation
import SwiftUI

// MARK: - Tabs

enum AppTab: Hashable {
    case home
    case checkURL
    case game
    case live
    case profile
}

// MARK: - URL Check Result

enum CheckResultKind: Equatable {
    case idle
    case checking
    case valid(code: Int)
    case invalid(reason: String)
    case unreachable(reason: String)
}

struct CheckResult: Equatable {
    let kind: CheckResultKind

    static let idle = CheckResult(kind: .idle)
    static let checking = CheckResult(kind: .checking)

    var title: String {
        switch kind {
        case .idle: return "Ready"
        case .checking: return "Checking link"
        case .valid: return "Link is live"
        case .invalid: return "Invalid link"
        case .unreachable: return "Unreachable"
        }
    }

    var detail: String {
        switch kind {
        case .idle:
            return "Paste an affiliate link and tap Check URL."
        case .checking:
            return "Contacting the destination server…"
        case .valid(let code):
            return code == 0
                ? "The destination responded successfully."
                : "The destination responded successfully (HTTP \(code))."
        case .invalid(let reason), .unreachable(let reason):
            return reason
        }
    }

    var symbol: String {
        switch kind {
        case .idle: return "link"
        case .checking: return "arrow.triangle.2.circlepath"
        case .valid: return "checkmark.seal.fill"
        case .invalid: return "xmark.octagon.fill"
        case .unreachable: return "wifi.exclamationmark"
        }
    }

    var tint: Color {
        switch kind {
        case .idle: return .brandTextSecondary
        case .checking: return .brandGold
        case .valid: return .brandGreen
        case .invalid: return .brandDanger
        case .unreachable: return .brandDanger
        }
    }

    var isSuccess: Bool {
        if case .valid = kind { return true }
        return false
    }
}

// MARK: - Link Check History

struct LinkCheckRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    let url: String
    let statusTitle: String
    let detail: String
    let date: Date
    let isSuccess: Bool
}

// MARK: - Feature / Quick Action

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let tab: AppTab
}
