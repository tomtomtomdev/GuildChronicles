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

// MARK: - Types

enum QuestBoardTab: String, CaseIterable {
    case available = "Available"
    case active = "Active"
    case chains = "Chains"
}

// MARK: - Subviews

struct AvailableQuestsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Quest Type Categories
                QuestCategoryCard(
                    title: "Bounty Hunts",
                    description: "Hunt down dangerous monsters and criminals",
                    icon: "target",
                    color: .red,
                    count: 3
                )

                QuestCategoryCard(
                    title: "Patron Requests",
                    description: "Special missions from your guild's patrons",
                    icon: "person.crop.circle.badge.checkmark",
                    color: .purple,
                    count: 1
                )

                QuestCategoryCard(
                    title: "Dungeon Expeditions",
                    description: "Explore dangerous dungeons for treasure",
                    icon: "door.left.hand.closed",
                    color: .orange,
                    count: 2
                )

                QuestCategoryCard(
                    title: "Emergency Response",
                    description: "Urgent situations requiring immediate attention",
                    icon: "exclamationmark.triangle.fill",
                    color: .yellow,
                    count: 0
                )

                QuestCategoryCard(
                    title: "Rival Encounters",
                    description: "Compete against rival guilds",
                    icon: "flag.2.crossed.fill",
                    color: .blue,
                    count: 1
                )
            }
            .padding()
        }
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
    var body: some View {
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
