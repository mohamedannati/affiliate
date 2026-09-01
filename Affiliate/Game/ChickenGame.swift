//
//  ChickenGame.swift
//  Affiliate
//
//  Play-money "Chicken" crash game inspired by MyStake.
//  Purely for entertainment — no real money involved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChickenGame: ObservableObject {

    enum Phase: Equatable {
        case waiting
        case running
        case crashed
        case cashedOut
    }

    // MARK: - Published state

    @Published private(set) var phase: Phase = .waiting
    @Published private(set) var multiplier: Double = 1.0
    @Published private(set) var crashPoint: Double = 1.0
    @Published private(set) var balance: Double = 1000.0
    @Published private(set) var bet: Double = 10.0
    @Published private(set) var lastWin: Double = 0.0
    @Published private(set) var roundCount: Int = 0

    // MARK: - Internals

    private var timer: Timer?
    private var betPlaced = false

    var canBet: Bool { phase == .waiting }
    var canCashOut: Bool { phase == .running && betPlaced }

    var formattedBalance: String { Self.formatMoney(balance) }
    var formattedBet: String { Self.formatMoney(bet) }
    var formattedLastWin: String { Self.formatMoney(lastWin) }

    // MARK: - Betting

    func setBet(_ value: Double) {
        guard phase == .waiting else { return }
        bet = min(max(value, 0), balance)
    }

    func placeBet() {
        guard canBet, bet > 0, bet <= balance else { return }
        balance -= bet
        betPlaced = true
        crashPoint = Self.generateCrashPoint()
        startRound()
    }

    // MARK: - Round lifecycle

    private func startRound() {
        multiplier = 1.0
        phase = .running
        let start = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick(start: start)
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick(start: Date) {
        let elapsed = Date().timeIntervalSince(start)
        multiplier = 1.0 + elapsed * 0.55

        if multiplier >= crashPoint {
            crash()
        }
    }

    func cashOut() {
        guard canCashOut else { return }
        let win = bet * multiplier
        balance += win
        lastWin = win
        betPlaced = false
        phase = .cashedOut
        stopTimer()
    }

    private func crash() {
        guard phase == .running else { return }
        phase = .crashed
        betPlaced = false
        lastWin = 0
        stopTimer()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - End / reset

    func endRound() {
        stopTimer()
        if betPlaced {
            // Refund an unfinished bet when leaving the screen.
            balance += bet
            betPlaced = false
        }
        roundCount += 1
        multiplier = 1.0
        phase = .waiting
    }

    // MARK: - Helpers

    private static func generateCrashPoint() -> Double {
        // House-favourable distribution: most rounds crash below 2x.
        let roll = Double.random(in: 0...1)
        if roll < 0.42 { return Double.random(in: 1.0...1.5) }
        if roll < 0.70 { return Double.random(in: 1.5...2.5) }
        if roll < 0.88 { return Double.random(in: 2.5...6.0) }
        return Double.random(in: 6.0...22.0)
    }

    static func formatMoney(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}
