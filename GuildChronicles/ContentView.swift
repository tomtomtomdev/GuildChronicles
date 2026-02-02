//
//  ContentView.swift
//  GuildChronicles
//
//  Root view that handles app navigation
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .mainMenu:
                MainMenuView()
            case .newCampaign:
                NewCampaignView()
            case .settings:
                SettingsView()
            case .mainGame:
                MainGameView()
            }
        }
        .environment(appState)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
