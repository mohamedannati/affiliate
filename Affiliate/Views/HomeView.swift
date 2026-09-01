//
//  HomeView.swift
//  Affiliate
//
//  Home dashboard: hero, quick actions, features and footer.
//

import SwiftUI

struct HomeView: View {
    @Binding var selection: AppTab

    private var features: [FeatureItem] {
        [
            FeatureItem(title: "Check URL",
                        subtitle: "Validate any affiliate link",
                        symbol: "link.badge.plus",
                        tint: .brandGreen,
                        tab: .checkURL),
            FeatureItem(title: "Chicken Game",
                        subtitle: "Play for fun, demo credits",
                        symbol: "gamecontroller.fill",
                        tint: .brandGold,
                        tab: .game),
            FeatureItem(title: "Live Site",
                        subtitle: "MyStake content in-app",
                        symbol: "globe",
                        tint: .brandGreen,
                        tab: .live)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        heroCard
                        quickActions
                        featuresSection
                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Affiliate")
                    .font(.display(20, .bold))
                    .foregroundStyle(.brandText)
                Text("MyStake companion")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.brandTextSecondary)
            }

            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.brandGold)
                .padding(10)
                .background(Circle().fill(Color.brandGold.opacity(0.12)))
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome to")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.brandTextSecondary)
                    Text("MyStake")
                        .font(.display(30, .heavy))
                        .foregroundStyle(.brandText)
                    Text("Premium affiliate companion for the MyStake casino platform.")
                        .font(.system(size: 14))
                        .foregroundStyle(.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image("Chicken")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
            }

            HStack(spacing: 10) {
                Button {
                    Haptics.impact()
                    UIApplication.shared.open(AppConfig.mainSite)
                } label: {
                    Label("Open mystake.com", systemImage: "safari.fill")
                        .font(.system(size: 15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background(.brand)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    Haptics.impact()
                    selection = .checkURL
                } label: {
                    Label("Check URL", systemImage: "link")
                        .font(.system(size: 15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.brandGold)
                .background(Capsule().strokeBorder(Color.brandGold.opacity(0.5), lineWidth: 1.5))
                .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color.brandSurfaceElevated, Color.brandSurface],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.brandGreen.opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.display(17, .bold))
                .foregroundStyle(.brandText)

            HStack(spacing: 12) {
                quickStat(title: "Links", value: "24/7", symbol: "bolt.fill", tint: .brandGreen)
                quickStat(title: "Payouts", value: "Fast", symbol: "banknote.fill", tint: .brandGold)
                quickStat(title: "Security", value: "SSL", symbol: "lock.shield.fill", tint: .brandGreen)
            }
        }
    }

    private func quickStat(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(Circle().fill(tint.opacity(0.14)))
            Text(value)
                .font(.display(16, .bold))
                .foregroundStyle(.brandText)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.brandSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.brandDivider, lineWidth: 1)
                )
        )
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore the app")
                .font(.display(17, .bold))
                .foregroundStyle(.brandText)

            VStack(spacing: 10) {
                ForEach(features) { feature in
                    Button {
                        Haptics.impact()
                        selection = feature.tab
                    } label: {
                        FeatureRow(feature: feature)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.brandGreen)
                Text("18+ · Play responsibly")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.brandTextSecondary)
            }
            Text("Affiliate v\(AppConfig.appVersion) · Demo credits only — no real money.")
                .font(.system(size: 11))
                .foregroundStyle(.brandTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 6)
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let feature: FeatureItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: feature.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(feature.tint)
                .frame(width: 46, height: 46)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(feature.tint.opacity(0.14)))

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.brandText)
                Text(feature.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.brandTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.brandTextSecondary.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.brandSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.brandDivider, lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView(selection: .constant(.home))
}
