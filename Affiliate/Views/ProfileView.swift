//
//  ProfileView.swift
//  Affiliate
//
//  Account profile and app settings.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("displayName") private var displayName = "Affiliate Partner"
    @State private var showAbout = false
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        statsRow
                        settingsSection
                        aboutSection
                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAbout) {
                AboutSheet()
                    .presentationDetents([.medium])
            }
            .confirmationDialog("Contact support", isPresented: $showSupport, titleVisibility: .visible) {
                Button("Email support") {
                    if let url = URL(string: "mailto:\(AppConfig.supportEmail)") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(AppConfig.supportEmail)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(Color.brandGreen.opacity(0.4), lineWidth: 1.5)
                )

            VStack(spacing: 4) {
                TextField("Your name", text: $displayName)
                    .font(.display(22, .bold))
                    .foregroundStyle(.brandText)
                    .multilineTextAlignment(.center)

                Text("MyStake Affiliate")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.brandGreen)
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.brandGreen)
                Text("Verified partner")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.brandTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.brandGreen.opacity(0.12)))
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "1,024", label: "Clicks", symbol: "cursorarrow.click.2")
            statCard(value: "312", label: "Sign-ups", symbol: "person.badge.plus")
            statCard(value: "4.8%", label: "Conversion", symbol: "chart.line.uptrend.xyaxis")
        }
    }

    private func statCard(value: String, label: String, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.brandGold)
            Text(value)
                .font(.mono(18, .bold))
                .foregroundStyle(.brandText)
            Text(label)
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

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.display(17, .bold))
                .foregroundStyle(.brandText)

            VStack(spacing: 0) {
                settingsRow(symbol: "safari.fill", title: "Open mystake.com", tint: .brandGreen) {
                    UIApplication.shared.open(AppConfig.mainSite)
                }
                Divider().overlay(Color.brandDivider)
                settingsRow(symbol: "envelope.fill", title: "Contact support", tint: .brandGold) {
                    showSupport = true
                }
                Divider().overlay(Color.brandDivider)
                settingsRow(symbol: "info.circle.fill", title: "About this app", tint: .brandTextSecondary) {
                    showAbout = true
                }
            }
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

    private func settingsRow(symbol: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(tint.opacity(0.14)))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.brandText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.brandTextSecondary.opacity(0.5))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.display(17, .bold))
                .foregroundStyle(.brandText)

            Text("Affiliate is an unofficial companion app for the MyStake platform. It includes a URL checker, an in-app browser and a demo game. All game credits are virtual and no real-money gambling is available in this app.")
                .font(.system(size: 13))
                .foregroundStyle(.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 4) {
            Text("Affiliate v\(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.brandTextSecondary)
            Text("Made with the MyStake color system")
                .font(.system(size: 11))
                .foregroundStyle(.brandTextSecondary.opacity(0.7))
        }
        .padding(.top, 4)
    }
}

// MARK: - About sheet

private struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack(spacing: 6) {
                    Text("Affiliate")
                        .font(.display(24, .heavy))
                        .foregroundStyle(.brandText)
                    Text("MyStake companion · v\(AppConfig.appVersion)")
                        .font(.system(size: 13))
                        .foregroundStyle(.brandTextSecondary)
                }

                Text("Built with SwiftUI for a clean, premium experience. Features include URL checking, live content browsing and a demo chicken game.")
                    .font(.system(size: 14))
                    .foregroundStyle(.brandTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(.brand)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ProfileView()
}
