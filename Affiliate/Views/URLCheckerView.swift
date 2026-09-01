//
//  URLCheckerView.swift
//  Affiliate
//
//  The "Check URL" tool: validates affiliate links against MyStake.
//

import SwiftUI

struct URLCheckerView: View {
    @StateObject private var history = HistoryStore()
    @State private var inputURL = AppConfig.defaultAffiliateURL
    @State private var result: CheckResult = .idle
    @State private var isChecking = false
    @State private var showClipboardToast = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        inputCard
                        resultCard
                        shortcutsCard
                        historySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Check URL")
            .navigationBarTitleDisplayMode(.large)
            .overlay(alignment: .bottom) { toast }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.brandGreen)
                .frame(width: 84, height: 84)
                .background(Circle().fill(Color.brandGreen.opacity(0.14)))
            Text("Link Checker")
                .font(.display(24, .heavy))
                .foregroundStyle(.brandText)
            Text("Paste any MyStake or affiliate URL below to verify it is live and reachable.")
                .font(.system(size: 14))
                .foregroundStyle(.brandTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Input card

    private var inputCard: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Affiliate URL")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.brandTextSecondary)

                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .foregroundStyle(.brandGreen)
                    TextField("https://mystake.com/...", text: $inputURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(.brandText)
                        .focused($focused)
                    if !inputURL.isEmpty {
                        Button {
                            inputURL = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.brandTextSecondary.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.brandSurfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(focused ? Color.brandGreen.opacity(0.6) : Color.brandDivider, lineWidth: 1)
                        )
                )
            }

            // The primary "Check URL" button
            Button(action: runCheck) {
                HStack(spacing: 10) {
                    if isChecking {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(isChecking ? "Checking…" : "Check URL")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(.brand)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(isChecking)
            .opacity(isChecking ? 0.7 : 1)
        }
        .cardStyle()
    }

    // MARK: - Result card

    private var resultCard: some View {
        VStack(spacing: 10) {
            Image(systemName: result.symbol)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(result.tint)

            Text(result.title)
                .font(.display(18, .bold))
                .foregroundStyle(.brandText)

            Text(result.detail)
                .font(.system(size: 13))
                .foregroundStyle(.brandTextSecondary)
                .multilineTextAlignment(.center)

            if case .valid = result.kind {
                Button {
                    UIPasteboard.general.string = inputURL
                    Haptics.success()
                    withAnimation { showClipboardToast = true }
                    Task {
                        try? await Task.sleep(nanoseconds: 1_600_000_000)
                        withAnimation { showClipboardToast = false }
                    }
                } label: {
                    Label("Copy link", systemImage: "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.brandGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.brandGreen.opacity(0.14)))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .opacity(result.kind == .idle ? 0.7 : 1)
    }

    // MARK: - Shortcuts

    private var shortcutsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick checks")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.brandTextSecondary)

            HStack(spacing: 10) {
                shortcutButton("mystake.com", url: "https://mystake.com")
                shortcutButton("Live content", url: AppConfig.liveContent.absoluteString)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(padding: 16)
    }

    private func shortcutButton(_ label: String, url: String) -> some View {
        Button {
            inputURL = url
            runCheck()
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.brandGold)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.brandGold.opacity(0.12)))
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent checks")
                    .font(.display(17, .bold))
                    .foregroundStyle(.brandText)
                Spacer()
                if !history.records.isEmpty {
                    Button("Clear") {
                        history.clear()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.brandTextSecondary)
                }
            }

            if history.records.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.brandTextSecondary.opacity(0.6))
                    Text("No checks yet. Your results will appear here.")
                        .font(.system(size: 13))
                        .foregroundStyle(.brandTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 18)
            } else {
                ForEach(history.records.prefix(10)) { record in
                    HStack(spacing: 12) {
                        Image(systemName: record.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(record.isSuccess ? .brandGreen : .brandDanger)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.url)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.brandText)
                                .lineLimit(1)
                            Text(record.statusTitle)
                                .font(.system(size: 12))
                                .foregroundStyle(.brandTextSecondary)
                        }
                        Spacer()
                        Text(record.date.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 12))
                            .foregroundStyle(.brandTextSecondary.opacity(0.7))
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Toast

    private var toast: some View {
        Group {
            if showClipboardToast {
                Label("Link copied", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.brandGreenDark))
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Actions

    private func runCheck() {
        guard !isChecking else { return }
        focused = false
        let raw = inputURL
        isChecking = true
        result = .checking
        Haptics.impact()

        Task {
            let outcome = await URLCheckerService.check(url: raw)
            result = outcome
            isChecking = false
            if outcome.isSuccess { Haptics.success() } else { Haptics.warning() }

            let record = LinkCheckRecord(url: raw,
                                         statusTitle: outcome.title,
                                         detail: outcome.detail,
                                         date: Date(),
                                         isSuccess: outcome.isSuccess)
            history.add(record)
        }
    }
}

#Preview {
    URLCheckerView()
}
