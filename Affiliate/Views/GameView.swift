//
//  GameView.swift
//  Affiliate
//
//  Demo "Chicken" crash game (play money only).
//

import SwiftUI

struct GameView: View {
    @StateObject private var game = ChickenGame()
    @State private var showRules = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        balanceBar
                        graphCard
                        betPanel
                        rulesHint
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Chicken Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showRules = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.brandTextSecondary)
                    }
                }
            }
            .sheet(isPresented: $showRules) {
                RulesSheet()
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            Image("Chicken")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text("Chicken")
                    .font(.display(22, .heavy))
                    .foregroundStyle(.brandText)
                Text("Cash out before it crashes")
                    .font(.system(size: 13))
                    .foregroundStyle(.brandTextSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Balance

    private var balanceBar: some View {
        HStack {
            Label {
                Text("Demo balance")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.brandTextSecondary)
            } icon: {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(.brandGold)
            }
            Spacer()
            Text(game.formattedBalance)
                .font(.mono(20, .bold))
                .foregroundStyle(.brandGold)
            Text("EUR")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.brandTextSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.brandSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.brandDivider, lineWidth: 1)
                )
        )
    }

    // MARK: - Graph

    private var graphCard: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.brandSurfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(multiplierColor.opacity(0.4), lineWidth: 1.5)
                    )

                VStack(spacing: 6) {
                    multiplierLabel
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.15), value: game.multiplier)

                    Image("Chicken")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .scaleEffect(runningScale)
                        .offset(y: game.phase == .running ? -8 : 0)
                        .animation(.interpolatingSpring(stiffness: 180, damping: 16), value: game.phase)
                }
            }
            .frame(height: 240)

            HStack(spacing: 12) {
                statusChip(title: "Status", value: statusText, color: multiplierColor)
                statusChip(title: "Last win", value: game.formattedLastWin, color: .brandGold)
                statusChip(title: "Round", value: "\(game.roundCount)", color: .brandTextSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.brandSurface)
        )
    }

    private var multiplierLabel: some View {
        Text(String(format: "%.2fx", game.multiplier))
            .font(.mono(40, .heavy))
            .foregroundStyle(multiplierColor)
            .shadow(color: multiplierColor.opacity(0.6), radius: 12)
    }

    private var runningScale: CGFloat {
        switch game.phase {
        case .running: return 1.05
        case .crashed: return 0.85
        case .cashedOut: return 1.15
        case .waiting: return 1.0
        }
    }

    private var statusText: String {
        switch game.phase {
        case .waiting: return "Waiting"
        case .running: return "Flying"
        case .crashed: return "Crashed"
        case .cashedOut: return "Cashed out"
        }
    }

    private var multiplierColor: Color {
        switch game.phase {
        case .running: return .brandGreen
        case .crashed: return .brandDanger
        case .cashedOut: return .brandGold
        case .waiting: return .brandTextSecondary
        }
    }

    private func statusChip(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.brandTextSecondary)
            Text(value)
                .font(.mono(15, .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.brandSurfaceElevated))
    }

    // MARK: - Bet panel

    private var betPanel: some View {
        VStack(spacing: 14) {
            Text("Bet amount")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.brandTextSecondary)

            HStack(spacing: 10) {
                ForEach([5.0, 10.0, 25.0, 50.0], id: \.self) { value in
                    betChip(value)
                }
            }

            if game.phase == .waiting {
                Button {
                    Haptics.impact(.medium)
                    game.placeBet()
                } label: {
                    Label("Place bet", systemImage: "arrow.up.right.circle.fill")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(.brand)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(game.bet <= 0 || game.bet > game.balance)
                .opacity(game.bet <= 0 || game.bet > game.balance ? 0.5 : 1)
            } else if game.canCashOut {
                Button {
                    Haptics.success()
                    game.cashOut()
                } label: {
                    Label("Cash out · \(String(format: "%.2fx", game.multiplier))", systemImage: "dollarsign.circle.fill")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(hex: 0x0B0E15))
                .background(.gold)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                Button {
                    Haptics.impact(.medium)
                    game.endRound()
                } label: {
                    Label("Play again", systemImage: "arrow.clockwise.circle.fill")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.brandSurfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.brandDivider, lineWidth: 1)
                        )
                )
            }
        }
        .cardStyle()
    }

    private func betChip(_ value: Double) -> some View {
        Button {
            Haptics.impact()
            game.setBet(value)
        } label: {
            Text("\(Int(value))")
                .font(.mono(15, .bold))
                .foregroundStyle(game.bet == value ? Color(hex: 0x0B0E15) : .brandText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(game.bet == value ? Color.brandGreen : Color.brandSurfaceElevated)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rules hint

    private var rulesHint: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.raised.fill")
                .foregroundStyle(.brandGold)
            Text("Demo mode: credits are virtual. This game is for entertainment only.")
                .font(.system(size: 12))
                .foregroundStyle(.brandTextSecondary)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Rules sheet

private struct RulesSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("How to play")
                            .font(.display(22, .heavy))
                            .foregroundStyle(.brandText)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(.brandTextSecondary.opacity(0.7))
                        }
                    }

                    ruleRow(number: "1", text: "Choose a bet amount using the chips, then tap Place bet.")
                    ruleRow(number: "2", text: "The multiplier climbs from 1.00x while the chicken flies.")
                    ruleRow(number: "3", text: "Cash out any time to lock in bet × multiplier.")
                    ruleRow(number: "4", text: "If the chicken crashes first, you lose the bet.")
                    ruleRow(number: "5", text: "All credits are virtual demo funds — no real money.")

                    Spacer(minLength: 8)

                    Button {
                        dismiss()
                    } label: {
                        Text("Got it")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(22)
            }
        }
    }

    private func ruleRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.mono(15, .bold))
                .foregroundStyle(.brandGreen)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.brandGreen.opacity(0.14)))
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    GameView()
}
