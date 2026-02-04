//
//  QuestDetailView.swift
//  GuildChronicles
//
//  Detailed quest view with party assignment
//

import SwiftUI

struct QuestDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let quest: Quest
    @State private var selectedPartyMembers: Set<UUID> = []

    private var guild: Guild? { appState.playerGuild }
    private var game: GameState? { appState.gameState }

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Quest Header
                    QuestHeaderCard(quest: quest)

                    // Quest Details
                    QuestInfoSection(quest: quest)

                    // Rewards
                    QuestRewardsSection(quest: quest)

                    // Party Selection
                    PartySelectionSection(
                        quest: quest,
                        selectedMembers: $selectedPartyMembers,
                        availableAdventurers: availableAdventurers
                    )

                    // Success Chance Preview
                    if !selectedPartyMembers.isEmpty {
                        SuccessChancePreview(
                            successChance: appState.calculateSuccessChance(
                                quest: quest,
                                partyMemberIds: selectedPartyMembers
                            )
                        )
                    }

                    // Accept Quest Button
                    AcceptQuestButton(
                        canAccept: canAcceptQuest,
                        partySize: selectedPartyMembers.count,
                        minSize: quest.minimumPartySize,
                        maxSize: quest.maximumPartySize
                    ) {
                        acceptQuest()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Quest Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var availableAdventurers: [Adventurer] {
        guard let game = game, let guild = guild else { return [] }
        return guild.rosterIDs.compactMap { game.getAdventurer(by: $0) }
            .filter { $0.isAvailableForQuests }
    }

    private var canAcceptQuest: Bool {
        selectedPartyMembers.count >= quest.minimumPartySize &&
        selectedPartyMembers.count <= quest.maximumPartySize
    }

    private func acceptQuest() {
        let success = appState.acceptQuest(
            questId: quest.id,
            partyMemberIds: selectedPartyMembers
        )
        if success {
            dismiss()
        }
    }
}

// MARK: - Success Chance Preview

struct SuccessChancePreview: View {
    let successChance: Double

    private var chancePercentage: Int {
        Int(successChance * 100)
    }

    private var chanceColor: Color {
        if successChance >= 0.8 { return .green }
        if successChance >= 0.6 { return .yellow }
        if successChance >= 0.4 { return .orange }
        return .red
    }

    private var chanceDescription: String {
        if successChance >= 0.8 { return "Excellent" }
        if successChance >= 0.6 { return "Good" }
        if successChance >= 0.4 { return "Risky" }
        return "Dangerous"
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(chanceColor)
                Text("Success Forecast")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack(spacing: 16) {
                // Circular progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: successChance)
                        .stroke(chanceColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))

                    Text("\(chancePercentage)%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(chanceDescription)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(chanceColor)

                    Text("Estimated success rate based on party strength vs quest difficulty")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(chanceColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(chanceColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Quest Header

struct QuestHeaderCard: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: quest.type.icon)
                    .font(.title)
                    .foregroundStyle(quest.stakes.uiColor)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(quest.stakes.uiColor.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        Text(quest.type.displayName)
                            .foregroundStyle(quest.stakes.uiColor)
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(quest.stakes.displayName + " Stakes")
                            .foregroundStyle(quest.stakes.uiColor)
                    }
                    .font(.subheadline)
                }

                Spacer()
            }

            // Stakes badge
            HStack {
                StakesBadge(stakes: quest.stakes)
                Spacer()
                Text("Est. \(quest.estimatedDurationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(quest.stakes.uiColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct StakesBadge: View {
    let stakes: QuestStakes

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: stakes.icon)
            Text(stakes.displayName + " Stakes")
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(stakes.uiColor.opacity(0.3))
        )
    }
}

// MARK: - Quest Info

struct QuestInfoSection: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .foregroundStyle(.white)

            Text(quest.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .background(.white.opacity(0.2))

            // Quest type info
            HStack {
                Image(systemName: "scroll.fill")
                    .foregroundStyle(.orange)
                Text("Type")
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text(quest.type.displayName)
                    .foregroundStyle(.white)
            }
            .font(.subheadline)

            // Party size
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(.blue)
                Text("Party Size")
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(quest.minimumPartySize)-\(quest.maximumPartySize) adventurers")
                    .foregroundStyle(.white)
            }
            .font(.subheadline)

            // Recommended level
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("Recommended Level")
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text(quest.recommendedLevel.displayName)
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Rewards

struct QuestRewardsSection: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rewards")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 20) {
                RewardCard(
                    icon: "banknote.fill",
                    value: "\(quest.effectiveReward)",
                    label: "Gold",
                    color: .yellow
                )

                RewardCard(
                    icon: "star.fill",
                    value: "+\(quest.experienceReward)",
                    label: "XP",
                    color: .blue
                )
            }

            if quest.lootTableID != nil {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.green)
                    Text("Possible loot drops based on quest outcome")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct RewardCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Party Selection

struct PartySelectionSection: View {
    let quest: Quest
    @Binding var selectedMembers: Set<UUID>
    let availableAdventurers: [Adventurer]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Select Party")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(selectedMembers.count)/\(quest.minimumPartySize)-\(quest.maximumPartySize)")
                    .font(.subheadline)
                    .foregroundStyle(
                        selectedMembers.count >= quest.minimumPartySize ? .green : .orange
                    )
            }

            if availableAdventurers.isEmpty {
                Text("No available adventurers in roster")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(availableAdventurers) { adventurer in
                    PartyMemberSelectionRow(
                        adventurer: adventurer,
                        isSelected: selectedMembers.contains(adventurer.id)
                    ) {
                        if selectedMembers.contains(adventurer.id) {
                            selectedMembers.remove(adventurer.id)
                        } else if selectedMembers.count < quest.maximumPartySize {
                            selectedMembers.insert(adventurer.id)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct PartyMemberSelectionRow: View {
    let adventurer: Adventurer
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .green : .white.opacity(0.3))

                Circle()
                    .fill(adventurer.primaryClass.roleColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(adventurer.primaryClass.abbreviation)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(adventurer.fullName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)

                    Text("\(adventurer.level.displayName) \(adventurer.primaryClass.displayName)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Avg: \(Int(adventurer.attributes.overallAverage))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.clear)
            )
        }
    }
}

// MARK: - Accept Button

struct AcceptQuestButton: View {
    let canAccept: Bool
    let partySize: Int
    let minSize: Int
    let maxSize: Int
    let onAccept: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onAccept) {
                HStack {
                    Image(systemName: "flag.fill")
                    Text("Accept Quest")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canAccept ? Color.green : Color.gray.opacity(0.3))
                )
            }
            .disabled(!canAccept)

            if partySize == 0 {
                Text("Select party members to accept quest")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else if partySize < minSize {
                Text("Need at least \(minSize) party members")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - QuestType Extensions

extension QuestType {
    var icon: String {
        switch self {
        case .investigation: return "magnifyingglass"
        case .combat: return "bolt.fill"
        case .exploration: return "map.fill"
        case .social: return "person.2.fill"
        case .ritual: return "wand.and.stars"
        case .siege: return "building.2.fill"
        case .escort: return "figure.walk"
        case .retrieval: return "archivebox.fill"
        case .assassination: return "target"
        case .defense: return "shield.fill"
        }
    }
}

extension QuestStakes {
    var icon: String {
        switch self {
        case .low: return "leaf"
        case .medium: return "flame"
        case .high: return "bolt.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }

    var uiColor: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

#Preview {
    NavigationStack {
        QuestDetailView(quest: .sample())
            .environment(AppState())
    }
}

extension Quest {
    static func sample() -> Quest {
        sample(name: "The Goblin Caves", type: .combat, stakes: .medium)
    }

    static func sample(name: String, type: QuestType, stakes: QuestStakes) -> Quest {
        let descriptions: [QuestType: String] = [
            .combat: "A dangerous combat mission requiring skilled warriors.",
            .exploration: "Explore unknown territories and uncover hidden secrets.",
            .retrieval: "Retrieve a valuable item from a guarded location.",
            .investigation: "Investigate mysterious occurrences and gather evidence.",
            .escort: "Safely escort a VIP through dangerous territory.",
            .defense: "Defend a location against incoming threats.",
            .social: "Navigate complex social situations with diplomacy.",
            .ritual: "Participate in or disrupt a magical ritual.",
            .siege: "Assault or defend a fortified position.",
            .assassination: "Eliminate a high-value target discreetly."
        ]

        return Quest(
            id: UUID(),
            name: name,
            description: descriptions[type] ?? "A challenging quest awaits.",
            type: type,
            stakes: stakes,
            status: .available,
            storyPosition: .prologue,
            segmentCount: 3,
            estimatedDurationMinutes: stakes == .low ? 20 : stakes == .high ? 45 : 30,
            minimumPartySize: stakes == .low ? 2 : 3,
            maximumPartySize: stakes == .critical ? 6 : 5,
            requiredClasses: [],
            recommendedLevel: stakes == .low ? .apprentice : stakes == .high ? .adept : .journeyman,
            baseGoldReward: stakes == .low ? 250 : stakes == .high ? 1000 : 500,
            experienceReward: stakes == .low ? 50 : stakes == .high ? 200 : 100,
            lootTableID: UUID(),
            prologueText: "Your guild has received a new mission...",
            successText: "Mission accomplished!",
            failureText: "The mission has failed...",
            partialSuccessText: nil,
            result: nil
        )
    }
}
