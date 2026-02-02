//
//  MainGameView.swift
//  GuildChronicles
//
//  Tab-based main game interface
//

import SwiftUI

struct MainGameView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(MainTab.dashboard.rawValue, systemImage: MainTab.dashboard.icon)
                }
                .tag(MainTab.dashboard)

            RosterListView()
                .tabItem {
                    Label(MainTab.roster.rawValue, systemImage: MainTab.roster.icon)
                }
                .tag(MainTab.roster)

            QuestBoardView()
                .tabItem {
                    Label(MainTab.quests.rawValue, systemImage: MainTab.quests.icon)
                }
                .tag(MainTab.quests)

            GuildManagementView()
                .tabItem {
                    Label(MainTab.guild.rawValue, systemImage: MainTab.guild.icon)
                }
                .tag(MainTab.guild)

            InventoryView()
                .tabItem {
                    Label(MainTab.inventory.rawValue, systemImage: MainTab.inventory.icon)
                }
                .tag(MainTab.inventory)
        }
        .tint(.yellow)
        .onChange(of: selectedTab) { _, newValue in
            state.selectedTab = newValue
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()

    MainGameView()
        .environment(appState)
        .onAppear {
            let game = GameState()
            game.campaignName = "Test Campaign"
            game.generateInitialFreeAgents(count: 20)
            let guild = Guild.create(
                name: "The Iron Wolves",
                motto: "Fortune Favors the Bold",
                homeRealm: .theEmpire,
                homeRegion: "Valorheim",
                tier: .fledgling,
                isPlayerControlled: true
            )
            game.playerGuildID = guild.id
            appState.gameState = game
            appState.playerGuild = guild
        }
}
