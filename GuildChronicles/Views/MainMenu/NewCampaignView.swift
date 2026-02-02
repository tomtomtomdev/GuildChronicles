//
//  NewCampaignView.swift
//  GuildChronicles
//
//  Campaign creation form
//

import SwiftUI

struct NewCampaignView: View {
    @Environment(AppState.self) private var appState

    // Form State
    @State private var campaignName: String = ""
    @State private var guildName: String = ""
    @State private var motto: String = ""
    @State private var selectedRealm: Realm = .theEmpire
    @State private var showingRealmPicker: Bool = false

    // Settings
    @State private var difficulty: DifficultyLevel = .normal
    @State private var permadeathEnabled: Bool = false
    @State private var attributeMasking: Bool = true
    @State private var tutorialEnabled: Bool = true

    private var isFormValid: Bool {
        !campaignName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !guildName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Campaign Details
                        FormSection(title: "Campaign Details") {
                            FormTextField(
                                title: "Campaign Name",
                                placeholder: "Enter campaign name",
                                text: $campaignName
                            )

                            FormTextField(
                                title: "Guild Name",
                                placeholder: "Enter your guild's name",
                                text: $guildName
                            )

                            FormTextField(
                                title: "Guild Motto",
                                placeholder: "Optional motto",
                                text: $motto
                            )
                        }

                        // Home Realm
                        FormSection(title: "Starting Location") {
                            RealmSelector(
                                selectedRealm: $selectedRealm,
                                showingPicker: $showingRealmPicker
                            )
                        }

                        // Difficulty Settings
                        FormSection(title: "Difficulty") {
                            DifficultyPicker(selection: $difficulty)
                        }

                        // Game Options
                        FormSection(title: "Game Options") {
                            FormToggle(
                                title: "Attribute Fog of War",
                                subtitle: "Adventurer stats partially hidden until observed",
                                isOn: $attributeMasking
                            )

                            FormToggle(
                                title: "Permadeath",
                                subtitle: "Fallen adventurers cannot be revived",
                                isOn: $permadeathEnabled
                            )

                            FormToggle(
                                title: "Tutorial",
                                subtitle: "Show guidance for new players",
                                isOn: $tutorialEnabled
                            )
                        }

                        // Start Button
                        Button(action: startCampaign) {
                            HStack {
                                Image(systemName: "flag.fill")
                                Text("Begin Your Journey")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isFormValid ? Color.green : Color.gray)
                            )
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        appState.returnToMainMenu()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func startCampaign() {
        let settings = GameSettings(
            attributeMaskingEnabled: attributeMasking,
            permadeathEnabled: permadeathEnabled,
            ironmanMode: false,
            difficultyLevel: difficulty,
            autoSaveEnabled: true,
            tutorialEnabled: tutorialEnabled
        )

        appState.createNewGame(
            campaignName: campaignName.trimmingCharacters(in: .whitespaces),
            guildName: guildName.trimmingCharacters(in: .whitespaces),
            motto: motto.trimmingCharacters(in: .whitespaces),
            homeRealm: selectedRealm,
            settings: settings
        )
    }
}

// MARK: - Form Components

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            VStack(spacing: 12) {
                content
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
}

struct FormTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3))
                )
                .foregroundStyle(.white)
        }
    }
}

struct FormToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
    }
}

struct RealmSelector: View {
    @Binding var selectedRealm: Realm
    @Binding var showingPicker: Bool

    // Only show Tier 1 realms for starting location
    private let starterRealms: [Realm] = Realm.allCases.filter { $0.tier == .tier1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Home Realm")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Menu {
                ForEach(starterRealms, id: \.self) { realm in
                    Button {
                        selectedRealm = realm
                    } label: {
                        HStack {
                            Text(realm.displayName)
                            if realm == selectedRealm {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedRealm.displayName)
                            .foregroundStyle(.white)

                        Text(selectedRealm.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3))
                )
            }
        }
    }
}

struct DifficultyPicker: View {
    @Binding var selection: DifficultyLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                DifficultyOption(
                    level: level,
                    isSelected: selection == level
                ) {
                    selection = level
                }
            }
        }
    }
}

struct DifficultyOption: View {
    let level: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void

    private var description: String {
        switch level {
        case .easy: return "Reduced enemy strength, increased rewards"
        case .normal: return "Balanced challenge for most players"
        case .hard: return "Increased enemy strength, reduced rewards"
        case .legendary: return "Maximum challenge for veterans"
        }
    }

    private var color: Color {
        switch level {
        case .easy: return .green
        case .normal: return .blue
        case .hard: return .orange
        case .legendary: return .red
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(isSelected ? color : .clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .strokeBorder(color, lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.white)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NewCampaignView()
        .environment(AppState())
}
