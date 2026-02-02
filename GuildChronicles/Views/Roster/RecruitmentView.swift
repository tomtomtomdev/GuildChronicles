//
//  RecruitmentView.swift
//  GuildChronicles
//
//  Browse and hire free agent adventurers
//

import SwiftUI

struct RecruitmentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var selectedClass: AdventurerClass? = nil
    @State private var selectedLevel: AdventurerLevel? = nil
    @State private var sortOption: RecruitmentSort = .value
    @State private var selectedAdventurer: Adventurer? = nil
    @State private var showingHireConfirmation: Bool = false

    private var game: GameState? { appState.gameState }
    private var guild: Guild? { appState.playerGuild }

    private var freeAgents: [Adventurer] {
        game?.freeAgentAdventurers ?? []
    }

    private var filteredAgents: [Adventurer] {
        var result = freeAgents

        // Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.primaryClass.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.race.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Class filter
        if let selectedClass = selectedClass {
            result = result.filter { $0.primaryClass == selectedClass }
        }

        // Level filter
        if let selectedLevel = selectedLevel {
            result = result.filter { $0.level == selectedLevel }
        }

        // Sort
        switch sortOption {
        case .value:
            result.sort { $0.estimatedValue > $1.estimatedValue }
        case .wage:
            result.sort { $0.weeklyWage < $1.weeklyWage }
        case .level:
            result.sort { $0.level.rawValue > $1.level.rawValue }
        case .name:
            result.sort { $0.fullName < $1.fullName }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header info
                    RecruitmentHeader(
                        agentCount: freeAgents.count,
                        treasury: guild?.finances.treasury ?? 0,
                        rosterSpace: (guild?.rosterCapacity ?? 0) - (guild?.totalRosterCount ?? 0)
                    )

                    // Filters
                    RecruitmentFilters(
                        searchText: $searchText,
                        selectedClass: $selectedClass,
                        selectedLevel: $selectedLevel,
                        sortOption: $sortOption
                    )

                    // List
                    if filteredAgents.isEmpty {
                        EmptyRecruitmentView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAgents) { agent in
                                    RecruitmentCard(
                                        adventurer: agent,
                                        canAfford: (guild?.finances.treasury ?? 0) >= agent.estimatedValue,
                                        hasSpace: (guild?.hasRosterSpace ?? false)
                                    ) {
                                        selectedAdventurer = agent
                                        showingHireConfirmation = true
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Recruitment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Hire Adventurer", isPresented: $showingHireConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Hire") {
                    if let adventurer = selectedAdventurer {
                        hireAdventurer(adventurer)
                    }
                }
            } message: {
                if let adventurer = selectedAdventurer {
                    Text("Hire \(adventurer.fullName) for \(adventurer.estimatedValue) gold?\n\nWeekly wage: \(adventurer.weeklyWage) gold")
                }
            }
        }
    }

    private func hireAdventurer(_ adventurer: Adventurer) {
        // This would update game state in a real implementation
        // For now, just dismiss
        dismiss()
    }
}

// MARK: - Sort Options

enum RecruitmentSort: String, CaseIterable {
    case value = "Value"
    case wage = "Wage"
    case level = "Level"
    case name = "Name"
}

// MARK: - Header

struct RecruitmentHeader: View {
    let agentCount: Int
    let treasury: Int
    let rosterSpace: Int

    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 2) {
                Text("\(agentCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Text("Available")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Divider()
                .frame(height: 40)
                .background(.white.opacity(0.2))

            VStack(spacing: 2) {
                Text("\(treasury)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
                Text("Treasury")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Divider()
                .frame(height: 40)
                .background(.white.opacity(0.2))

            VStack(spacing: 2) {
                Text("\(rosterSpace)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(rosterSpace > 0 ? .green : .red)
                Text("Roster Space")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Filters

struct RecruitmentFilters: View {
    @Binding var searchText: String
    @Binding var selectedClass: AdventurerClass?
    @Binding var selectedLevel: AdventurerLevel?
    @Binding var sortOption: RecruitmentSort

    var body: some View {
        VStack(spacing: 8) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.5))

                TextField("Search adventurers...", text: $searchText)
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

            // Filter row
            HStack(spacing: 8) {
                // Class filter
                Menu {
                    Button("All Classes") {
                        selectedClass = nil
                    }
                    Divider()
                    ForEach(AdventurerClass.allCases, id: \.self) { cls in
                        Button(cls.displayName) {
                            selectedClass = cls
                        }
                    }
                } label: {
                    FilterChip(
                        label: selectedClass?.displayName ?? "Class",
                        isActive: selectedClass != nil
                    )
                }

                // Level filter
                Menu {
                    Button("All Levels") {
                        selectedLevel = nil
                    }
                    Divider()
                    ForEach(AdventurerLevel.allCases, id: \.self) { level in
                        Button(level.displayName) {
                            selectedLevel = level
                        }
                    }
                } label: {
                    FilterChip(
                        label: selectedLevel?.displayName ?? "Level",
                        isActive: selectedLevel != nil
                    )
                }

                Spacer()

                // Sort
                Menu {
                    ForEach(RecruitmentSort.allCases, id: \.self) { sort in
                        Button {
                            sortOption = sort
                        } label: {
                            HStack {
                                Text(sort.rawValue)
                                if sort == sortOption {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.rawValue)
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct FilterChip: View {
    let label: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
            Image(systemName: "chevron.down")
                .font(.caption2)
        }
        .font(.caption)
        .foregroundStyle(isActive ? .white : .white.opacity(0.7))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isActive ? Color.blue.opacity(0.5) : Color.white.opacity(0.1))
        )
    }
}

// MARK: - Recruitment Card

struct RecruitmentCard: View {
    let adventurer: Adventurer
    let canAfford: Bool
    let hasSpace: Bool
    let onHire: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(adventurer.primaryClass.roleColor)
                    .frame(width: 56, height: 56)
                    .overlay(
                        VStack(spacing: 0) {
                            Text(adventurer.primaryClass.abbreviation)
                                .font(.caption)
                                .fontWeight(.bold)
                            Text(adventurer.level.abbreviation)
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                    )

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(adventurer.fullName)
                        .font(.headline)
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Text(adventurer.race.displayName)
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(adventurer.primaryClass.displayName)
                            .foregroundStyle(adventurer.primaryClass.roleColor)
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                    // Key stats preview
                    HStack(spacing: 12) {
                        StatPreview(label: "Overall", value: Int(adventurer.attributes.overallAverage))
                        StatPreview(label: "Combat", value: Int(adventurer.attributes.combatAverage))
                    }
                }

                Spacer()

                // Cost & hire
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(adventurer.estimatedValue)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(canAfford ? .yellow : .red)

                    Text("gold")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    Text("\(adventurer.weeklyWage)/wk")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            // Hire button
            Button(action: onHire) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Hire")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(canAfford && hasSpace ? Color.green.opacity(0.6) : Color.gray.opacity(0.3))
                )
            }
            .disabled(!canAfford || !hasSpace)
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

struct StatPreview: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.white.opacity(0.5))
            Text("\(value)")
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .font(.caption)
    }
}

// MARK: - Empty View

struct EmptyRecruitmentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.2))

            Text("No Matches Found")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))

            Text("Try adjusting your filters to find more adventurers.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

// MARK: - AdventurerLevel Extension

extension AdventurerLevel {
    var abbreviation: String {
        switch self {
        case .apprentice: return "Apr"
        case .journeyman: return "Jrn"
        case .adept: return "Adp"
        case .expert: return "Exp"
        case .master: return "Mst"
        case .grandmaster: return "GMst"
        case .legendary: return "Leg"
        }
    }
}

#Preview {
    let appState = AppState()
    let game = GameState()
    game.generateInitialFreeAgents(count: 30)

    let guild = Guild.create(
        name: "Test Guild",
        motto: "Test",
        homeRealm: .theEmpire,
        homeRegion: "Test",
        tier: .fledgling,
        isPlayerControlled: true
    )

    appState.gameState = game
    appState.playerGuild = guild

    return RecruitmentView()
        .environment(appState)
}
