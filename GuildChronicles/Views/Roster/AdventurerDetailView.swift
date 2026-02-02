//
//  AdventurerDetailView.swift
//  GuildChronicles
//
//  Detailed view of a single adventurer
//

import SwiftUI

struct AdventurerDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let adventurer: Adventurer
    @State private var selectedTab: AdventurerTab = .stats

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    AdventurerHeaderCard(adventurer: adventurer)

                    // Tab Selector
                    AdventurerTabSelector(selectedTab: $selectedTab)

                    // Tab Content
                    switch selectedTab {
                    case .stats:
                        AdventurerStatsSection(adventurer: adventurer)
                    case .attributes:
                        AdventurerAttributesSection(adventurer: adventurer)
                    case .career:
                        AdventurerCareerSection(adventurer: adventurer)
                    case .equipment:
                        AdventurerEquipmentSection(adventurer: adventurer)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(adventurer.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Tab Types

enum AdventurerTab: String, CaseIterable {
    case stats = "Stats"
    case attributes = "Attributes"
    case career = "Career"
    case equipment = "Equipment"
}

// MARK: - Header Card

struct AdventurerHeaderCard: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 16) {
                // Large avatar
                Circle()
                    .fill(adventurer.primaryClass.roleColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        VStack(spacing: 2) {
                            Text(adventurer.primaryClass.abbreviation)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Lv.\(adventurer.level.displayName)")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(adventurer.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        Text(adventurer.race.displayName)
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(adventurer.primaryClass.displayName)
                            .foregroundStyle(adventurer.primaryClass.roleColor)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                    HStack(spacing: 8) {
                        Text("Age \(adventurer.age)")
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(adventurer.homeRealm.displayName)
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()
            }

            // Status badges
            HStack(spacing: 8) {
                StatusBadge(
                    text: adventurer.contractStatus.displayName,
                    color: adventurer.contractStatus.color
                )

                StatusBadge(
                    text: adventurer.currentCondition.displayName,
                    color: adventurer.currentCondition.color
                )

                if adventurer.isInjured {
                    StatusBadge(text: "Injured", color: .red)
                }

                Spacer()

                // Value
                VStack(alignment: .trailing) {
                    Text("Value")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(adventurer.estimatedValue) gold")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.yellow)
                }
            }

            // Wage info
            HStack {
                Label("\(adventurer.weeklyWage)/week", systemImage: "banknote")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                Label("\(Int(adventurer.lootSharePercent * 100))% loot share", systemImage: "bag")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(adventurer.primaryClass.roleColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.3))
            )
    }
}

// MARK: - Tab Selector

struct AdventurerTabSelector: View {
    @Binding var selectedTab: AdventurerTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AdventurerTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == tab ?
                            Color.blue.opacity(0.3) : Color.clear
                        )
                }
            }
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Stats Section

struct AdventurerStatsSection: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(spacing: 16) {
            // Combat stats
            StatGroupCard(title: "Combat", icon: "bolt.fill") {
                StatRow(label: "Melee Combat", value: adventurer.attributes[.meleeCombat])
                StatRow(label: "Ranged Combat", value: adventurer.attributes[.rangedCombat])
                StatRow(label: "Defense", value: adventurer.attributes[.defense])
                StatRow(label: "Initiative", value: adventurer.attributes[.initiative])
            }

            // Physical stats
            StatGroupCard(title: "Physical", icon: "figure.run") {
                StatRow(label: "Strength", value: adventurer.attributes[.strength])
                StatRow(label: "Dexterity", value: adventurer.attributes[.dexterity])
                StatRow(label: "Constitution", value: adventurer.attributes[.constitution])
                StatRow(label: "Endurance", value: adventurer.attributes[.endurance])
            }

            // Mental stats
            StatGroupCard(title: "Mental", icon: "brain") {
                StatRow(label: "Wisdom", value: adventurer.attributes[.wisdom])
                StatRow(label: "Charisma", value: adventurer.attributes[.charisma])
                StatRow(label: "Willpower", value: adventurer.attributes[.willpower])
                StatRow(label: "Perception", value: adventurer.attributes[.perception])
            }

            // Magic stats (if spellcaster)
            if adventurer.primaryClass.isSpellcaster {
                StatGroupCard(title: "Magic", icon: "wand.and.stars") {
                    StatRow(label: "Arcane Power", value: adventurer.attributes[.arcanePower])
                    StatRow(label: "Mana Pool", value: adventurer.attributes[.manaPool])
                    StatRow(label: "Concentration", value: adventurer.attributes[.concentration])
                    StatRow(label: "Channeling", value: adventurer.attributes[.channeling])
                }
            }
        }
    }
}

struct StatGroupCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct StatRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            // Stat bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(statColor(value))
                        .frame(width: geometry.size.width * CGFloat(min(value, 100)) / 100)
                }
            }
            .frame(width: 80, height: 8)

            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(statColor(value))
                .frame(width: 30, alignment: .trailing)
        }
    }

    private func statColor(_ value: Int) -> Color {
        switch value {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .yellow
        case 20..<40: return .orange
        default: return .red
        }
    }
}

// MARK: - Attributes Section

struct AdventurerAttributesSection: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(spacing: 16) {
            AttributeAveragesCard(adventurer: adventurer)
            ClassPrimaryAttributesCard(adventurer: adventurer)
            RacialModifiersCard(adventurer: adventurer)
        }
    }
}

struct AttributeAveragesCard: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attribute Averages")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                AverageStatCard(title: "Overall", value: adventurer.attributes.overallAverage, color: .blue)
                AverageStatCard(title: "Combat", value: adventurer.attributes.combatAverage, color: .red)
                AverageStatCard(title: "Physical", value: adventurer.attributes.physicalAverage, color: .orange)
                AverageStatCard(title: "Mental", value: adventurer.attributes.mentalAverage, color: .purple)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ClassPrimaryAttributesCard: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Class Primary Attributes")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(adventurer.primaryClass.primaryAttributes, id: \.self) { attr in
                StatRow(label: attr.displayName, value: adventurer.attributes[attr])
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct RacialModifiersCard: View {
    let adventurer: Adventurer

    private var mods: RaceAttributeModifiers {
        adventurer.race.attributeModifiers
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Racial Modifiers (\(adventurer.race.displayName))")
                .font(.headline)
                .foregroundStyle(.white)

            RacialModifierRow(label: "Strength", mod: mods.strength)
            RacialModifierRow(label: "Dexterity", mod: mods.dexterity)
            RacialModifierRow(label: "Constitution", mod: mods.constitution)
            RacialModifierRow(label: "Wisdom", mod: mods.wisdom)
            RacialModifierRow(label: "Charisma", mod: mods.charisma)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct RacialModifierRow: View {
    let label: String
    let mod: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(mod > 0 ? "+\(mod)" : "\(mod)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(mod > 0 ? .green : .red)
        }
    }
}

struct AverageStatCard: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", value))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Career Section

struct AdventurerCareerSection: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(spacing: 16) {
            // Performance
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    CareerStatCard(
                        title: "Quests Done",
                        value: "\(adventurer.statistics.questsCompleted)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    CareerStatCard(
                        title: "Quests Failed",
                        value: "\(adventurer.statistics.questsFailed)",
                        icon: "xmark.circle.fill",
                        color: .red
                    )
                    CareerStatCard(
                        title: "Success Rate",
                        value: String(format: "%.0f%%", adventurer.statistics.successRate * 100),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    )
                }

                if adventurer.statistics.performanceRatingCount > 0 {
                    HStack {
                        Text("Average Rating")
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", adventurer.statistics.averagePerformanceRating))
                                .fontWeight(.semibold)
                                .foregroundStyle(.yellow)
                        }
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )

            // Combat record
            VStack(alignment: .leading, spacing: 12) {
                Text("Combat Record")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    CareerStatCard(
                        title: "Monsters Slain",
                        value: "\(adventurer.statistics.monstersSlain)",
                        icon: "flame.fill",
                        color: .orange
                    )
                    CareerStatCard(
                        title: "Dungeons Cleared",
                        value: "\(adventurer.statistics.dungeonsCleared)",
                        icon: "door.left.hand.closed",
                        color: .purple
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )

            // Financial
            VStack(alignment: .leading, spacing: 12) {
                Text("Financial")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack {
                    Text("Treasure Acquired")
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text("\(adventurer.statistics.treasureValueAcquired) gold")
                        .fontWeight(.semibold)
                        .foregroundStyle(.yellow)
                }
                .font(.subheadline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )

            // Injuries & Survival
            VStack(alignment: .leading, spacing: 12) {
                Text("Survival")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    CareerStatCard(
                        title: "Injuries",
                        value: "\(adventurer.statistics.injuriesSustained)",
                        icon: "bandage.fill",
                        color: .red
                    )
                    CareerStatCard(
                        title: "Deaths Survived",
                        value: "\(adventurer.statistics.deathsSurvived)",
                        icon: "heart.fill",
                        color: .pink
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

struct CareerStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Equipment Section

struct AdventurerEquipmentSection: View {
    let adventurer: Adventurer

    var body: some View {
        VStack(spacing: 16) {
            Text("Equipment")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Equipment slots placeholder
            VStack(spacing: 12) {
                EquipmentSlotRow(slot: "Main Hand", item: nil)
                EquipmentSlotRow(slot: "Off Hand", item: nil)
                EquipmentSlotRow(slot: "Head", item: nil)
                EquipmentSlotRow(slot: "Chest", item: nil)
                EquipmentSlotRow(slot: "Hands", item: nil)
                EquipmentSlotRow(slot: "Feet", item: nil)
                EquipmentSlotRow(slot: "Ring 1", item: nil)
                EquipmentSlotRow(slot: "Ring 2", item: nil)
                EquipmentSlotRow(slot: "Amulet", item: nil)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )

            Text("Equipment management coming in future update")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

struct EquipmentSlotRow: View {
    let slot: String
    let item: String?

    var body: some View {
        HStack {
            Text(slot)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 80, alignment: .leading)

            Spacer()

            if let item = item {
                Text(item)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            } else {
                Text("Empty")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.3))
                    .italic()
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}

// MARK: - Supporting Extensions

extension ContractStatus {
    var displayName: String {
        switch self {
        case .freeAgent: return "Free Agent"
        case .underContract: return "Under Contract"
        case .onLoan: return "On Loan"
        case .retiring: return "Retiring"
        }
    }

    var color: Color {
        switch self {
        case .freeAgent: return .green
        case .underContract: return .blue
        case .onLoan: return .orange
        case .retiring: return .gray
        }
    }
}

extension AdventurerCondition {
    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var color: Color {
        switch self {
        case .healthy: return .green
        case .fatigued: return .yellow
        case .recovering: return .orange
        case .injured: return .red
        case .cursed: return .purple
        case .deceased: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        AdventurerDetailView(adventurer: .random(level: .expert))
            .environment(AppState())
    }
}
