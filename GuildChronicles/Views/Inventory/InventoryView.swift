//
//  InventoryView.swift
//  GuildChronicles
//
//  Guild inventory management
//

import SwiftUI

struct InventoryView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedCategory: InventoryCategory = .all

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(InventoryCategory.allCases, id: \.self) { category in
                                InventoryCategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.2))

                    // Inventory Content
                    ScrollView {
                        VStack(spacing: 16) {
                            // Gold Display
                            GoldDisplayCard()

                            // Inventory placeholder
                            InventoryPlaceholder(category: selectedCategory)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // Sort by name
                        } label: {
                            Label("Sort by Name", systemImage: "textformat")
                        }

                        Button {
                            // Sort by rarity
                        } label: {
                            Label("Sort by Rarity", systemImage: "star.fill")
                        }

                        Button {
                            // Sort by value
                        } label: {
                            Label("Sort by Value", systemImage: "banknote")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
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

enum InventoryCategory: String, CaseIterable {
    case all = "All"
    case weapons = "Weapons"
    case armor = "Armor"
    case accessories = "Accessories"
    case consumables = "Consumables"
    case materials = "Materials"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .weapons: return "bolt.fill"
        case .armor: return "shield.fill"
        case .accessories: return "sparkles"
        case .consumables: return "flask.fill"
        case .materials: return "cube.fill"
        }
    }
}

struct InventoryCategoryButton: View {
    let category: InventoryCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.purple.opacity(0.6) : Color.white.opacity(0.1))
            )
        }
    }
}

// MARK: - Subviews

struct GoldDisplayCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack {
            Image(systemName: "banknote.fill")
                .font(.title2)
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("Treasury")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Text("\(appState.playerGuild?.finances.treasury ?? 0) gold")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
            }

            Spacer()

            Button {
                // Shop action
            } label: {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.6))
                )
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

struct InventoryPlaceholder: View {
    let category: InventoryCategory

    private var showWeapons: Bool {
        category == .all || category == .weapons
    }

    private var showArmor: Bool {
        category == .all || category == .armor
    }

    private var showConsumables: Bool {
        category == .all || category == .consumables
    }

    private var showEmpty: Bool {
        category == .accessories || category == .materials
    }

    var body: some View {
        VStack(spacing: 20) {
            if showWeapons {
                InventoryItemRow(name: "Iron Sword", type: "Weapon", rarity: .common, quantity: 3)
                InventoryItemRow(name: "Steel Longsword", type: "Weapon", rarity: .uncommon, quantity: 1)
            }

            if showArmor {
                InventoryItemRow(name: "Leather Armor", type: "Armor", rarity: .common, quantity: 2)
            }

            if showConsumables {
                InventoryItemRow(name: "Health Potion", type: "Consumable", rarity: .common, quantity: 10)
                InventoryItemRow(name: "Mana Potion", type: "Consumable", rarity: .common, quantity: 5)
            }

            if showEmpty {
                EmptyInventoryMessage(category: category)
            }
        }
    }
}

struct InventoryItemRow: View {
    let name: String
    let type: String
    let rarity: ItemRarity
    let quantity: Int

    var body: some View {
        HStack(spacing: 12) {
            // Item icon placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(rarity.color.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: iconForType(type))
                        .foregroundStyle(rarity.color)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(rarity.color)

                HStack(spacing: 8) {
                    Text(type)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("•")
                        .foregroundStyle(.white.opacity(0.3))

                    Text(rarity.displayName)
                        .font(.caption)
                        .foregroundStyle(rarity.color)
                }
            }

            Spacer()

            if quantity > 1 {
                Text("×\(quantity)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
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
                        .strokeBorder(rarity.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func iconForType(_ type: String) -> String {
        switch type {
        case "Weapon": return "bolt.fill"
        case "Armor": return "shield.fill"
        case "Accessory": return "sparkles"
        case "Consumable": return "flask.fill"
        default: return "cube.fill"
        }
    }
}

struct EmptyInventoryMessage: View {
    let category: InventoryCategory

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.2))

            Text("No \(category.rawValue)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))

            Text("Find items on quests or purchase from shops")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - ItemRarity UI Extensions

extension ItemRarity {
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

#Preview {
    InventoryView()
        .environment(AppState())
}
