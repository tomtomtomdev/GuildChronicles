//
//  DashboardView.swift
//  GuildChronicles
//
//  Main dashboard/home view showing guild overview
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    private var game: GameState? { appState.gameState }
    private var guild: Guild? { appState.playerGuild }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                if let guild = guild, let game = game {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Season Banner
                            SeasonBanner(game: game)

                            // Quick Stats Grid
                            QuickStatsGrid(guild: guild)

                            // Treasury Card
                            TreasuryCard(guild: guild)

                            // Active Quests Summary
                            ActiveQuestsSummary()

                            // Recent Events
                            RecentEventsCard()
                        }
                        .padding()
                    }
                } else {
                    Text("No active game")
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .navigationTitle(guild?.name ?? "Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.advanceWeek()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Next Week")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.cyan)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Menu action
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Dashboard Components

struct SeasonBanner: View {
    let game: GameState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(game.campaignName)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Season \(game.currentSeason) - \(game.seasonPhase.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Month \(game.currentMonth)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Text("Week \(game.weekInSeason)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: seasonColors(for: game.seasonPhase),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }

    private func seasonColors(for phase: SeasonPhase) -> [Color] {
        switch phase {
        case .springThaw:
            return [Color.green.opacity(0.6), Color.teal.opacity(0.6)]
        case .summerCampaign:
            return [Color.orange.opacity(0.6), Color.yellow.opacity(0.6)]
        case .autumnHarvest:
            return [Color.orange.opacity(0.6), Color.brown.opacity(0.6)]
        case .wintersEnd:
            return [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]
        }
    }
}

struct QuickStatsGrid: View {
    let guild: Guild

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Roster",
                value: "\(guild.rosterCount)/\(guild.rosterCapacity)",
                icon: "person.3.fill",
                color: .blue
            )

            StatCard(
                title: "Reputation",
                value: guild.reputation.level.displayName,
                icon: "star.fill",
                color: .yellow
            )

            StatCard(
                title: "Guild Tier",
                value: guild.tier.displayName,
                icon: "crown.fill",
                color: .purple
            )

            StatCard(
                title: "Staff",
                value: "\(guild.staff.count)",
                icon: "person.badge.key.fill",
                color: .green
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct TreasuryCard: View {
    let guild: Guild

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "banknote.fill")
                    .foregroundStyle(.yellow)
                Text("Treasury")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack(alignment: .bottom, spacing: 4) {
                Text("\(guild.finances.treasury)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.yellow)

                Text("gold")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 6)
            }

            Divider()
                .background(.white.opacity(0.2))

            HStack {
                VStack(alignment: .leading) {
                    Text("Weekly Costs")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("-\(guild.weeklyOperatingCosts)")
                        .foregroundStyle(.red.opacity(0.8))
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Weekly Income")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("+\(guild.weeklyIncome)")
                        .foregroundStyle(.green.opacity(0.8))
                }
            }

            if guild.isInFinancialTrouble {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Low reserves! Consider taking a loan.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ActiveQuestsSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "scroll.fill")
                    .foregroundStyle(.orange)
                Text("Active Quests")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()

                Button("View All") {
                    // Navigate to quests
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }

            // Placeholder for active quests
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.white.opacity(0.3))
                Text("No active quests")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct RecentEventsCard: View {
    @Environment(AppState.self) private var appState

    private var recentEvents: [GameEvent] {
        appState.gameState?.recentEvents.reversed() ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "newspaper.fill")
                    .foregroundStyle(.cyan)
                Text("Recent Events")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            if recentEvents.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No events yet")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recentEvents.prefix(5)) { event in
                        EventRow(
                            icon: event.type.icon,
                            text: event.message,
                            time: event.timestamp.shortDisplay,
                            color: event.type.color
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct EventRow: View {
    let icon: String
    let text: String
    let time: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text(time)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()

    DashboardView()
        .environment(appState)
        .onAppear {
            let game = GameState()
            game.campaignName = "Chronicles of Valor"
            let guild = Guild.create(
                name: "The Iron Wolves",
                motto: "Fortune Favors the Bold",
                homeRealm: .theEmpire,
                homeRegion: "Valorheim",
                tier: .fledgling,
                isPlayerControlled: true
            )
            appState.gameState = game
            appState.playerGuild = guild
        }
}
