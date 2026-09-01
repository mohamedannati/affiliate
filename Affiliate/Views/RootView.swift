//
//  RootView.swift
//  Affiliate
//
//  Main tab bar navigation.
//

import SwiftUI

struct RootView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            HomeView(selection: $selection)
                .tag(AppTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            URLCheckerView()
                .tag(AppTab.checkURL)
                .tabItem { Label("Check URL", systemImage: "link.badge.plus") }

            GameView()
                .tag(AppTab.game)
                .tabItem { Label("Game", systemImage: "gamecontroller.fill") }

            LiveWebView()
                .tag(AppTab.live)
                .tabItem { Label("Live", systemImage: "globe") }

            ProfileView()
                .tag(AppTab.profile)
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(.brandGreen)
    }
}

#Preview {
    RootView()
}
