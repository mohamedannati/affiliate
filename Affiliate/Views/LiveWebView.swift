//
//  LiveWebView.swift
//  Affiliate
//
//  In-app browser showing the live MyStake content from mystake.great-site.net
//

import SwiftUI
import WebKit

struct LiveWebView: View {
    @State private var isLoading = true
    @State private var showActions = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    LiveWebRepresentable(isLoading: $isLoading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if isLoading {
                        ProgressView("Loading live content…")
                            .font(.system(size: 13))
                            .foregroundStyle(.brandTextSecondary)
                            .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Live Site")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showActions = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.brandTextSecondary)
                    }
                    .confirmationDialog("Live Site", isPresented: $showActions, titleVisibility: .visible) {
                        Button("Reload") { reload() }
                        Button("Open in Safari") {
                            UIApplication.shared.open(AppConfig.liveContent)
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
    }

    private func reload() {
        isLoading = true
        NotificationCenter.default.post(name: .affiliateReloadWeb, object: nil)
    }
}

// MARK: - WKWebView wrapper

struct LiveWebRepresentable: UIViewRepresentable {
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.043, green: 0.055, blue: 0.082, alpha: 1)
        webView.scrollView.backgroundColor = UIColor(red: 0.043, green: 0.055, blue: 0.082, alpha: 1)

        context.coordinator.load(in: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Coordinator handles loading and reloads; no update work required here.
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: LiveWebRepresentable
        private weak var webView: WKWebView?
        private var hasLoaded = false

        init(_ parent: LiveWebRepresentable) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(reload),
                                                   name: .affiliateReloadWeb,
                                                   object: nil)
        }

        func load(in webView: WKWebView) {
            guard !hasLoaded else { return }
            hasLoaded = true
            var request = URLRequest(url: AppConfig.liveContent)
            request.timeoutInterval = 30
            webView.load(request)
        }

        @objc private func reload() {
            guard let webView = webView else { return }
            var request = URLRequest(url: AppConfig.liveContent)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            webView.load(request)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.webView = webView
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

extension Notification.Name {
    static let affiliateReloadWeb = Notification.Name("affiliate.reload.web")
}

#Preview {
    LiveWebView()
}
