//
//  QuestBoardView.swift
//  GuildChronicles
//
//  Quest board showing available and active quests
//

import SwiftUI

struct QuestBoardView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedSegment: QuestBoardTab = .available

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segment Picker
                    Picker("Quest Type", selection: $selectedSegment) {
                        ForEach(QuestBoardTab.allCases, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Content based on segment
                    switch selectedSegment {
                    case .available:
                        AvailableQuestsView()
                    case .active:
                        ActiveQuestsView()
                    case .chains:
                        QuestChainsView()
                    }
                }
            }
            .navigationDestination(for: Quest.self) { quest in
                QuestDetailView(quest: quest)
            }
            .navigationDestination(for: QuestCategory.self) { category in
                QuestCategoryListView(category: category)
            }
            .navigationTitle("Quest Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Refresh quests
                    } label: {
                        Image(systemName: "arrow.clockwise")
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

// MARK: - Quest Category List

struct QuestCategoryListView: View {
    @Environment(AppState.self) private var appState
    let category: QuestCategory

    private var availableQuests: [Quest] {
        appState.gameState?.availableQuests ?? []
    }

    private var filteredQuests: [Quest] {
        availableQuests.filter { quest in
            switch category {
            case .bounty:
                return quest.type == .combat || quest.type == .assassination
            case .patron:
                return quest.type == .retrieval || quest.type == .escort || quest.type == .social
            case .dungeon:
                return quest.type == .exploration
            case .rival:
                return quest.type == .defense || quest.type == .siege
            case .emergency:
                return quest.stakes == .critical
            }
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15)
                .ignoresSafeArea()

            if filteredQuests.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "scroll.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white.opacity(0.2))

                    Text("No Quests Available")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Check back later for new opportunities.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredQuests) { quest in
                            NavigationLink(value: quest) {
                                QuestRowCard(quest: quest)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Types

enum QuestBoardTab: String, CaseIterable {
    case available = "Available"
    case active = "Active"
    case chains = "Chains"
}

// MARK: - Subviews

struct AvailableQuestsView: View {
    @Environment(AppState.self) private var appState

    private var availableQuests: [Quest] {
        appState.gameState?.availableQuests ?? []
    }

    private func questCount(for category: QuestCategory) -> Int {
        availableQuests.filter { quest in
            switch category {
            case .bounty:
                return quest.type == .combat || quest.type == .assassination
            case .patron:
                return quest.type == .retrieval || quest.type == .escort || quest.type == .social
            case .dungeon:
                return quest.type == .exploration
            case .rival:
                return quest.type == .defense || quest.type == .siege
            case .emergency:
                return quest.stakes == .critical
            }
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let bountyCount = questCount(for: .bounty)
                let patronCount = questCount(for: .patron)
                let dungeonCount = questCount(for: .dungeon)
                let rivalCount = questCount(for: .rival)
                let emergencyCount = questCount(for: .emergency)

                // Quest Type Categories
                if bountyCount > 0 {
                    NavigationLink(value: QuestCategory.bounty) {
                        QuestCategoryCard(
                            title: "Bounty Hunts",
                            description: "Hunt down dangerous monsters and criminals",
                            icon: "target",
                            color: .red,
                            count: bountyCount
                        )
                    }
                    .buttonStyle(.plain)
                }

                if patronCount > 0 {
                    NavigationLink(value: QuestCategory.patron) {
                        QuestCategoryCard(
                            title: "Patron Requests",
                            description: "Special missions from your guild's patrons",
                            icon: "person.crop.circle.badge.checkmark",
                            color: .purple,
                            count: patronCount
                        )
                    }
                    .buttonStyle(.plain)
                }

                if dungeonCount > 0 {
                    NavigationLink(value: QuestCategory.dungeon) {
                        QuestCategoryCard(
                            title: "Dungeon Expeditions",
                            description: "Explore dangerous dungeons for treasure",
                            icon: "door.left.hand.closed",
                            color: .orange,
                            count: dungeonCount
                        )
                    }
                    .buttonStyle(.plain)
                }

                if emergencyCount > 0 {
                    NavigationLink(value: QuestCategory.emergency) {
                        QuestCategoryCard(
                            title: "Emergency Response",
                            description: "Urgent situations requiring immediate attention",
                            icon: "exclamationmark.triangle.fill",
                            color: .yellow,
                            count: emergencyCount
                        )
                    }
                    .buttonStyle(.plain)
                }

                if rivalCount > 0 {
                    NavigationLink(value: QuestCategory.rival) {
                        QuestCategoryCard(
                            title: "Rival Encounters",
                            description: "Compete against rival guilds",
                            icon: "flag.2.crossed.fill",
                            color: .blue,
                            count: rivalCount
                        )
                    }
                    .buttonStyle(.plain)
                }

                if availableQuests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "scroll.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.2))

                        Text("No Quests Available")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))

                        Text("Advance time to refresh the quest board.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding()
        }
    }
}

enum QuestCategory: String, Hashable {
    case bounty = "Bounty Hunts"
    case patron = "Patron Requests"
    case dungeon = "Dungeon Expeditions"
    case emergency = "Emergency Response"
    case rival = "Rival Encounters"
}

struct QuestRowCard: View {
    let quest: Quest

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.type.icon)
                .font(.title2)
                .foregroundStyle(quest.stakes.uiColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(quest.stakes.uiColor.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(quest.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text(quest.type.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("•")
                        .foregroundStyle(.white.opacity(0.3))

                    Text(quest.stakes.displayName)
                        .font(.caption)
                        .foregroundStyle(quest.stakes.uiColor)
                }

                HStack(spacing: 12) {
                    Label("\(quest.effectiveReward)", systemImage: "banknote.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)

                    Label("\(quest.minimumPartySize)-\(quest.maximumPartySize)", systemImage: "person.3.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(quest.stakes.uiColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct QuestCategoryCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let count: Int

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Count Badge
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(color)
                    )
            } else {
                Text("None")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }

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

struct ActiveQuestsView: View {
    @Environment(AppState.self) private var appState

    private var activeQuests: [Quest] {
        appState.gameState?.activeQuests ?? []
    }

    var body: some View {
        if activeQuests.isEmpty {
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "scroll.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.2))

                Text("No Active Quests")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))

                Text("Accept a quest from the Available tab to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(activeQuests) { quest in
                        NavigationLink(value: quest) {
                            QuestRowCard(quest: quest)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

struct QuestChainsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Example Quest Chains
                QuestChainCard(
                    title: "The Goblin Threat",
                    tier: .regional,
                    progress: 0,
                    totalQuests: 5,
                    isAvailable: true
                )

                QuestChainCard(
                    title: "Shadows of the Past",
                    tier: .realm,
                    progress: 0,
                    totalQuests: 8,
                    isAvailable: false
                )

                QuestChainCard(
                    title: "The Dragon's Awakening",
                    tier: .continental,
                    progress: 0,
                    totalQuests: 12,
                    isAvailable: false
                )
            }
            .padding()
        }
    }
}

struct QuestChainCard: View {
    let title: String
    let tier: QuestChainTier
    let progress: Int
    let totalQuests: Int
    let isAvailable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Tier Badge
                Text(tier.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(tier.color)
                    )

                Spacer()

                if !isAvailable {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                        Text("Locked")
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                }
            }

            Text(title)
                .font(.headline)
                .foregroundStyle(isAvailable ? .white : .white.opacity(0.5))

            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(tier.color)
                            .frame(width: geometry.size.width * CGFloat(progress) / CGFloat(totalQuests))
                    }
                }
                .frame(height: 8)

                Text("\(progress)/\(totalQuests) Quests Completed")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isAvailable ? 0.05 : 0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(isAvailable ? 1.0 : 0.6)
    }
}

// MARK: - QuestChainTier UI Extensions

extension QuestChainTier {
    var color: Color {
        switch self {
        case .regional: return .green
        case .realm: return .blue
        case .continental: return .purple
        case .legendary: return .orange
        }
    }
}

#Preview {
    QuestBoardView()
        .environment(AppState())
}
