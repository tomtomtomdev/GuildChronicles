//
//  SettingsView.swift
//  GuildChronicles
//
//  App settings screen
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Audio Settings
                        FormSection(title: "Audio") {
                            SettingsRow(
                                icon: "speaker.wave.3.fill",
                                title: "Sound Effects",
                                value: "On"
                            )

                            SettingsRow(
                                icon: "music.note",
                                title: "Music",
                                value: "On"
                            )
                        }

                        // Display Settings
                        FormSection(title: "Display") {
                            SettingsRow(
                                icon: "textformat.size",
                                title: "Text Size",
                                value: "Medium"
                            )

                            SettingsRow(
                                icon: "speedometer",
                                title: "Animation Speed",
                                value: "Normal"
                            )
                        }

                        // Game Settings
                        FormSection(title: "Game") {
                            SettingsRow(
                                icon: "arrow.counterclockwise",
                                title: "Auto-Save",
                                value: "Every Turn"
                            )

                            SettingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                value: "All"
                            )
                        }

                        // About Section
                        FormSection(title: "About") {
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: "Version",
                                value: "0.1.0"
                            )

                            SettingsRow(
                                icon: "doc.text.fill",
                                title: "Credits",
                                value: ""
                            )
                        }

                        // Placeholder text
                        Text("Full settings implementation coming soon")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
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
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.white)

            Spacer()

            if !value.isEmpty {
                Text(value)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
