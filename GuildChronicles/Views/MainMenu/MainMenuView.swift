//
//  MainMenuView.swift
//  GuildChronicles
//
//  Landing screen with game options
//

import SwiftUI

struct MainMenuView: View {
    @Environment(AppState.self) private var appState
    @State private var showingLoadGame = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Guild")
                        .font(.system(size: 56, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("Chronicles")
                        .font(.system(size: 48, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("A Guild Master Simulation")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 4)
                }

                Spacer()

                // Menu Buttons
                VStack(spacing: 16) {
                    MenuButton(
                        title: "New Campaign",
                        icon: "plus.circle.fill",
                        color: .green
                    ) {
                        appState.startNewCampaign()
                    }

                    MenuButton(
                        title: "Continue",
                        icon: "play.circle.fill",
                        color: .blue,
                        isDisabled: !appState.hasActiveGame
                    ) {
                        appState.enterGame()
                    }

                    MenuButton(
                        title: "Load Game",
                        icon: "folder.fill",
                        color: .orange,
                        isDisabled: appState.savedGames.isEmpty
                    ) {
                        showingLoadGame = true
                    }

                    MenuButton(
                        title: "Settings",
                        icon: "gearshape.fill",
                        color: .gray
                    ) {
                        appState.showSettings()
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Version
                Text("Version 0.1.0")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingLoadGame) {
            LoadGameView()
        }
    }
}

// MARK: - Load Game View

struct LoadGameView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                if appState.savedGames.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("No Saved Games")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))

                        Text("Start a new campaign to begin your adventure")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                } else {
                    List {
                        ForEach(appState.savedGames) { save in
                            SavedGameRow(save: save) {
                                if appState.loadGame(name: save.name) {
                                    dismiss()
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let save = appState.savedGames[index]
                                _ = appState.deleteSave(name: save.name)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Load Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct SavedGameRow: View {
    let save: SaveInfo
    let onLoad: () -> Void

    var body: some View {
        Button(action: onLoad) {
            HStack(spacing: 16) {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(save.guildName)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(save.campaignName) • Season \(save.season)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(save.displayDate)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Menu Button Component

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isDisabled ? 0.3 : 0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    MainMenuView()
        .environment(AppState())
}
