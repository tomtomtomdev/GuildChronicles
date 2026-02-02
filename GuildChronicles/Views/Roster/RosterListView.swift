//
//  RosterListView.swift
//  GuildChronicles
//
//  Adventurer roster management view
//

import SwiftUI

struct RosterListView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText: String = ""
    @State private var filterClass: AdventurerClass? = nil
    @State private var sortOption: RosterSortOption = .name

    private var game: GameState? { appState.gameState }
    private var guild: Guild? { appState.playerGuild }

    private var rosterAdventurers: [Adventurer] {
        guard let game = game, let guild = guild else { return [] }
        return guild.rosterIDs.compactMap { game.getAdventurer(by: $0) }
    }

    private var filteredAdventurers: [Adventurer] {
        var result = rosterAdventurers

        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Class filter
        if let filterClass = filterClass {
            result = result.filter { $0.primaryClass == filterClass }
        }

        // Sort
        switch sortOption {
        case .name:
            result.sort { $0.fullName < $1.fullName }
        case .level:
            result.sort { $0.level.rawValue > $1.level.rawValue }
        case .class_:
            result.sort { $0.primaryClass.displayName < $1.primaryClass.displayName }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Roster Stats Header
                    RosterStatsHeader(
                        rosterCount: guild?.rosterCount ?? 0,
                        capacity: guild?.rosterCapacity ?? 0,
                        apprentices: guild?.apprenticeIDs.count ?? 0
                    )

                    // Search and Filter Bar
                    SearchFilterBar(
                        searchText: $searchText,
                        sortOption: $sortOption
                    )

                    // Roster List
                    if rosterAdventurers.isEmpty {
                        EmptyRosterView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAdventurers) { adventurer in
                                    AdventurerRowCard(adventurer: adventurer)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Roster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Recruit action
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(.green)
                    }
                }
            }
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Supporting Types

enum RosterSortOption: String, CaseIterable {
    case name = "Name"
    case level = "Level"
    case class_ = "Class"

    var icon: String {
        switch self {
        case .name: return "textformat"
        case .level: return "arrow.up.circle"
        case .class_: return "person.crop.square"
        }
    }
}

// MARK: - Subviews

struct RosterStatsHeader: View {
    let rosterCount: Int
    let capacity: Int
    let apprentices: Int

    var body: some View {
        HStack(spacing: 20) {
            RosterStatBadge(
                title: "Active",
                value: "\(rosterCount)",
                color: .blue
            )

            RosterStatBadge(
                title: "Capacity",
                value: "\(capacity)",
                color: .gray
            )

            RosterStatBadge(
                title: "Apprentices",
                value: "\(apprentices)",
                color: .purple
            )
        }
        .padding()
        .background(Color.black.opacity(0.2))
    }
}

struct RosterStatBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SearchFilterBar: View {
    @Binding var searchText: String
    @Binding var sortOption: RosterSortOption

    var body: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.5))

                TextField("Search adventurers", text: $searchText)
                    .foregroundStyle(.white)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
            )

            // Sort Menu
            Menu {
                ForEach(RosterSortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        HStack {
                            Image(systemName: option.icon)
                            Text(option.rawValue)
                            if option == sortOption {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct AdventurerRowCard: View {
    let adventurer: Adventurer

    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(adventurer.primaryClass.roleColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(adventurer.primaryClass.abbreviation)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(adventurer.fullName)
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text(adventurer.race.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("•")
                        .foregroundStyle(.white.opacity(0.3))

                    Text(adventurer.primaryClass.displayName)
                        .font(.caption)
                        .foregroundStyle(adventurer.primaryClass.roleColor)
                }

                // Status indicators
                HStack(spacing: 6) {
                    StatusPill(
                        text: adventurer.level.displayName,
                        color: .blue
                    )

                    if adventurer.isInjured {
                        StatusPill(
                            text: "Injured",
                            color: .red
                        )
                    }

                    if !adventurer.isAvailableForQuests {
                        StatusPill(
                            text: "Busy",
                            color: .orange
                        )
                    }
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.3))
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

struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.3))
            )
    }
}

struct EmptyRosterView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.2))

            Text("No Adventurers Yet")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))

            Text("Visit the Recruitment Board to hire adventurers for your guild.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                // Navigate to recruitment
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Recruit Adventurers")
                }
                .foregroundStyle(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.6))
                )
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}

// MARK: - AdventurerClass Extensions for UI

extension AdventurerClass {
    var roleColor: Color {
        switch category {
        case .martial: return .red
        case .spellcasting: return .blue
        case .hybrid: return .purple
        }
    }

    var abbreviation: String {
        switch self {
        case .fighter: return "FGT"
        case .barbarian: return "BAR"
        case .paladin: return "PAL"
        case .ranger: return "RNG"
        case .monk: return "MNK"
        case .rogue: return "ROG"
        case .wizard: return "WIZ"
        case .sorcerer: return "SOR"
        case .cleric: return "CLR"
        case .druid: return "DRU"
        case .warlock: return "WLK"
        case .bard: return "BRD"
        case .artificer: return "ART"
        case .eldritchKnight: return "EKN"
        case .arcaneTrickster: return "ATK"
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()

    RosterListView()
        .environment(appState)
        .onAppear {
            let game = GameState()
            game.generateInitialFreeAgents(count: 10)
            var guild = Guild.create(
                name: "Test Guild",
                motto: "Test",
                homeRealm: .theEmpire,
                homeRegion: "Test",
                tier: .fledgling,
                isPlayerControlled: true
            )
            let adventurers = Array(game.freeAgentAdventurers.prefix(5))
            for adventurer in adventurers {
                guild.rosterIDs.append(adventurer.id)
            }
            appState.gameState = game
            appState.playerGuild = guild
        }
}
