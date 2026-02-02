//
//  GuildManagementView.swift
//  GuildChronicles
//
//  Guild facilities, staff, and council management
//

import SwiftUI

struct GuildManagementView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedSection: GuildSection = .facilities

    private var guild: Guild? { appState.playerGuild }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Section Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(GuildSection.allCases, id: \.self) { section in
                                GuildSectionButton(
                                    section: section,
                                    isSelected: selectedSection == section
                                ) {
                                    selectedSection = section
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.2))

                    // Content
                    if let guild = guild {
                        ScrollView {
                            switch selectedSection {
                            case .facilities:
                                FacilitiesSection(facilities: guild.facilities)
                            case .staff:
                                StaffSection(staff: guild.staff)
                            case .council:
                                CouncilSection(council: guild.council)
                            case .finances:
                                FinancesSection(guild: guild)
                            }
                        }
                    } else {
                        Text("No guild data")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .navigationTitle("Guild Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Types

enum GuildSection: String, CaseIterable {
    case facilities = "Facilities"
    case staff = "Staff"
    case council = "Council"
    case finances = "Finances"

    var icon: String {
        switch self {
        case .facilities: return "building.2.fill"
        case .staff: return "person.3.fill"
        case .council: return "person.crop.circle.badge.checkmark"
        case .finances: return "banknote.fill"
        }
    }
}

struct GuildSectionButton: View {
    let section: GuildSection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: section.icon)
                Text(section.rawValue)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.1))
            )
        }
    }
}

// MARK: - Facilities Section

struct FacilitiesSection: View {
    let facilities: GuildFacilities

    var body: some View {
        VStack(spacing: 16) {
            FacilityCard(facility: facilities.guildHall, name: "Guild Hall", icon: "house.fill")
            FacilityCard(facility: facilities.trainingGrounds, name: "Training Grounds", icon: "figure.strengthtraining.traditional")
            FacilityCard(facility: facilities.apprenticeAcademy, name: "Apprentice Academy", icon: "graduationcap.fill")
            FacilityCard(facility: facilities.library, name: "Library", icon: "books.vertical.fill")
            FacilityCard(facility: facilities.temple, name: "Temple", icon: "building.columns.fill")
            FacilityCard(facility: facilities.tavern, name: "Tavern", icon: "mug.fill")
            FacilityCard(facility: facilities.armory, name: "Armory", icon: "shield.fill")
        }
        .padding()
    }
}

struct FacilityCard: View {
    let facility: Facility
    let name: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(facility.rating.uiColor)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(facility.rating.displayName)
                        .font(.caption)
                        .foregroundStyle(facility.rating.uiColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Condition")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    Text("\(facility.condition)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(conditionColor(facility.condition))
                }
            }

            Text(facility.type.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

            // Condition bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(conditionColor(facility.condition))
                        .frame(width: geometry.size.width * CGFloat(facility.condition) / 100)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Maintenance: \(facility.weeklyMaintenanceCost)/week")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Button("Upgrade") { }
                    .font(.caption)
                    .foregroundStyle(.blue)
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

    private func conditionColor(_ condition: Int) -> Color {
        switch condition {
        case 80...100: return .green
        case 50..<80: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
}

// MARK: - Staff Section

struct StaffSection: View {
    let staff: [StaffMember]

    var body: some View {
        VStack(spacing: 16) {
            if staff.isEmpty {
                EmptyStaffView()
            } else {
                ForEach(staff) { member in
                    StaffMemberCard(member: member)
                }
            }

            Button {
                // Hire staff
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Hire Staff")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.6))
                )
            }
        }
        .padding()
    }
}

struct StaffMemberCard: View {
    let member: StaffMember

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(member.role.uiColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: member.role.uiIcon)
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(member.role.displayName)
                    .font(.caption)
                    .foregroundStyle(member.role.uiColor)

                HStack(spacing: 12) {
                    Text("Skill: \(member.skillLevel)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Salary: \(member.weeklySalary)/week")
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
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct EmptyStaffView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.2))

            Text("No staff hired")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Council Section

struct CouncilSection: View {
    let council: Council

    var body: some View {
        VStack(spacing: 16) {
            // Council Overview
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Council Status")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Text(council.confidenceStatus.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(council.confidenceStatus.uiColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Confidence: \(council.overallConfidence)%")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(council.confidenceStatus.uiColor)
                                .frame(width: geometry.size.width * CGFloat(council.overallConfidence) / 100)
                        }
                    }
                    .frame(height: 8)
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

            Text("Guild Patrons")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(council.patrons) { patron in
                PatronCard(patron: patron)
            }
        }
        .padding()
    }
}

struct PatronCard: View {
    let patron: Patron

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(patron.type.uiColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: patron.type.uiIcon)
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(patron.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(patron.type.displayName)
                    .font(.caption)
                    .foregroundStyle(patron.type.uiColor)

                Text(patron.personality.displayName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Influence")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Text("\(patron.influence)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.yellow)
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

// MARK: - Finances Section

struct FinancesSection: View {
    let guild: Guild

    var body: some View {
        VStack(spacing: 16) {
            // Treasury Overview
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "banknote.fill")
                        .foregroundStyle(.yellow)
                    Text("Treasury")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                Text("\(guild.finances.treasury)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.yellow)

                Text("gold pieces")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
            )

            // Weekly Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Summary")
                    .font(.headline)
                    .foregroundStyle(.white)

                FinanceRow(label: "Wage Bill", amount: -guild.weeklyWageBill, color: .red)
                FinanceRow(label: "Staff Salaries", amount: -guild.weeklyStaffSalaries, color: .red)
                FinanceRow(label: "Maintenance", amount: -guild.facilities.totalWeeklyMaintenance, color: .red)

                Divider().background(.white.opacity(0.2))

                FinanceRow(label: "Tavern Income", amount: guild.weeklyIncome, color: .green)

                Divider().background(.white.opacity(0.2))

                let netWeekly = guild.weeklyIncome - guild.weeklyOperatingCosts
                FinanceRow(
                    label: "Net Weekly",
                    amount: netWeekly,
                    color: netWeekly >= 0 ? .green : .red,
                    isBold: true
                )
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

            // Loans
            if !guild.loans.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Loans")
                        .font(.headline)
                        .foregroundStyle(.white)

                    ForEach(guild.loans) { loan in
                        LoanRow(loan: loan)
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

            Button {
                // Request loan
            } label: {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Request Loan")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.6))
                )
            }
        }
        .padding()
    }
}

struct FinanceRow: View {
    let label: String
    let amount: Int
    let color: Color
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(isBold ? .subheadline.bold() : .subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text(amount >= 0 ? "+\(amount)" : "\(amount)")
                .font(isBold ? .subheadline.bold() : .subheadline)
                .foregroundStyle(color)
        }
    }
}

struct LoanRow: View {
    let loan: Loan

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(loan.lenderName)
                    .font(.subheadline)
                    .foregroundStyle(.white)

                Text("Due: \(loan.weeksRemaining) weeks")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Text("\(loan.remainingBalance) gold")
                .font(.subheadline)
                .foregroundStyle(.red)
        }
    }
}

// MARK: - UI Extensions

extension StaffRole {
    var uiColor: Color {
        switch self {
        case .secondInCommand: return .purple
        case .combatInstructor: return .red
        case .magicInstructor: return .blue
        case .healerOnRetainer: return .green
        case .scoutMaster: return .orange
        case .apprenticeMaster: return .teal
        case .quartermaster: return .gray
        case .chronicler: return .cyan
        }
    }

    var uiIcon: String {
        switch self {
        case .secondInCommand: return "crown.fill"
        case .combatInstructor: return "figure.fencing"
        case .magicInstructor: return "wand.and.stars"
        case .healerOnRetainer: return "cross.fill"
        case .scoutMaster: return "binoculars.fill"
        case .apprenticeMaster: return "graduationcap.fill"
        case .quartermaster: return "shippingbox.fill"
        case .chronicler: return "book.fill"
        }
    }
}

extension FacilityRating {
    var uiColor: Color {
        switch self {
        case .ramshackle: return .red
        case .poor: return .orange
        case .adequate: return .yellow
        case .good: return .green
        case .excellent: return .blue
        case .masterwork: return .purple
        case .legendary: return .yellow
        }
    }
}

extension ConfidenceStatus {
    var uiColor: Color {
        switch self {
        case .secure: return .green
        case .stable: return .blue
        case .concerning: return .yellow
        case .critical: return .orange
        case .failing: return .red
        }
    }
}

extension PatronType {
    var uiColor: Color {
        switch self {
        case .benefactor: return .yellow
        case .veteran: return .red
        case .representative: return .blue
        case .chronicler: return .purple
        case .arbiter: return .gray
        }
    }

    var uiIcon: String {
        switch self {
        case .benefactor: return "banknote.fill"
        case .veteran: return "shield.fill"
        case .representative: return "person.3.fill"
        case .chronicler: return "book.fill"
        case .arbiter: return "scale.3d"
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()

    GuildManagementView()
        .environment(appState)
        .onAppear {
            let guild = Guild.create(
                name: "The Iron Wolves",
                motto: "Fortune Favors the Bold",
                homeRealm: .theEmpire,
                homeRegion: "Imperial Heartland",
                tier: .fledgling,
                isPlayerControlled: true
            )
            appState.playerGuild = guild
        }
}
