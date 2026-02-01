//
//  GuildModelTests.swift
//  GuildChroniclesTests
//
//  Tests for Guild, Staff, Facilities, Council, and Finances models
//

import Testing
import Foundation
@testable import GuildChronicles

struct GuildModelTests {

    // MARK: - Staff Tests

    @Test func staffRoleProperties() async throws {
        #expect(StaffRole.secondInCommand.allowsMultiple == false)
        #expect(StaffRole.combatInstructor.allowsMultiple == true)
        #expect(StaffRole.secondInCommand.baseWeeklySalary > StaffRole.chronicler.baseWeeklySalary)
    }

    @Test func staffMemberGeneration() async throws {
        let instructor = StaffMember.random(role: .combatInstructor)
        #expect(instructor.role == .combatInstructor)
        #expect(instructor.combatSpecialization != nil)
        #expect(instructor.skillLevel >= 8 && instructor.skillLevel <= 16)
    }

    @Test func combatSpecializationAttributes() async throws {
        let meleeAttrs = CombatSpecialization.melee.trainedAttributes
        #expect(meleeAttrs.contains(.meleeCombat))
        #expect(meleeAttrs.contains(.strength))
    }

    @Test func magicSpecializationAttributes() async throws {
        let arcaneAttrs = MagicSpecialization.arcane.trainedAttributes
        #expect(arcaneAttrs.contains(.arcanePower))
        #expect(arcaneAttrs.contains(.manaPool))
    }

    // MARK: - Facilities Tests

    @Test func facilityRatingProgression() async throws {
        #expect(FacilityRating.ramshackle < FacilityRating.legendary)
        #expect(FacilityRating.adequate.effectivenessMultiplier == 1.0)
        #expect(FacilityRating.legendary.effectivenessMultiplier > FacilityRating.ramshackle.effectivenessMultiplier)
    }

    @Test func facilityConditionAffectsRating() async throws {
        var facility = Facility.basic(.trainingGrounds)
        #expect(facility.effectiveRating == .adequate)

        facility.condition = 40
        #expect(facility.effectiveRating.rawValue < facility.rating.rawValue)

        facility.condition = 20
        #expect(facility.effectiveRating.rawValue < facility.rating.rawValue - 1)
    }

    @Test func guildFacilitiesCalculations() async throws {
        let facilities = GuildFacilities.starter
        #expect(facilities.rosterCapacity > 0)
        #expect(facilities.totalWeeklyMaintenance > 0)
        #expect(facilities.tavernIncome > 0)
    }

    // MARK: - Council Tests

    @Test func patronPersonalityTraits() async throws {
        #expect(PatronPersonality.glorySeeker.patience == .veryLow)
        #expect(PatronPersonality.glorySeeker.generosity == .veryHigh)
        #expect(PatronPersonality.cautious.patience == .high)
        #expect(PatronPersonality.cautious.generosity == .veryLow)
    }

    @Test func patronGeneration() async throws {
        let patron = Patron.random(type: .benefactor)
        #expect(patron.type == .benefactor)
        #expect(patron.influence >= 40 && patron.influence <= 80)
    }

    @Test func councilStarterHasAllPatronTypes() async throws {
        let council = Council.starter()
        #expect(council.patrons.count == PatronType.allCases.count)

        for type in PatronType.allCases {
            #expect(council.patrons.contains { $0.type == type })
        }
    }

    @Test func confidenceStatusThresholds() async throws {
        var council = Council.starter()

        council.overallConfidence = 85
        #expect(council.confidenceStatus == .secure)

        council.overallConfidence = 65
        #expect(council.confidenceStatus == .stable)

        council.overallConfidence = 45
        #expect(council.confidenceStatus == .concerning)

        council.overallConfidence = 25
        #expect(council.confidenceStatus == .critical)

        council.overallConfidence = 10
        #expect(council.confidenceStatus == .failing)
    }

    @Test func ultimatumCreation() async throws {
        let ultimatum = Ultimatum.random(type: .consecutiveSuccesses, currentWeek: 10)
        #expect(ultimatum.type == .consecutiveSuccesses)
        #expect(ultimatum.targetValue == 3)
        #expect(ultimatum.deadlineWeek > 10)
        #expect(ultimatum.isComplete == false)
    }

    // MARK: - Finances Tests

    @Test func financialTransactionTypes() async throws {
        let income = FinancialTransaction.income(
            week: 1,
            amount: 1000,
            type: .questReward,
            description: "Quest completed"
        )
        #expect(income.isIncome == true)
        #expect(income.amount == 1000)

        let expense = FinancialTransaction.expense(
            week: 1,
            amount: 500,
            type: .adventurerSalaries,
            description: "Weekly wages"
        )
        #expect(expense.isIncome == false)
        #expect(expense.amount == -500)
    }

    @Test func financialLedgerCalculations() async throws {
        var ledger = FinancialLedger.empty

        ledger.record(.income(week: 1, amount: 1000, type: .questReward, description: "Quest 1"))
        ledger.record(.income(week: 1, amount: 500, type: .tavernIncome, description: "Tavern"))
        ledger.record(.expense(week: 1, amount: 300, type: .adventurerSalaries, description: "Wages"))

        #expect(ledger.totalIncome == 1500)
        #expect(ledger.totalExpenses == 300)
        #expect(ledger.netBalance == 1200)
    }

    @Test func loanCalculations() async throws {
        let loan = Loan.merchantLoan(amount: 1000, currentWeek: 1)

        #expect(loan.principalAmount == 1000)
        #expect(loan.totalOwed > 1000)  // Interest applied
        #expect(loan.interestRate == 0.15)
        #expect(loan.isPaidOff == false)
    }

    @Test func templeLoanHasLowerInterest() async throws {
        let merchantLoan = Loan.merchantLoan(amount: 1000, currentWeek: 1)
        let templeLoan = Loan.templeLoan(amount: 1000, currentWeek: 1)

        #expect(templeLoan.interestRate < merchantLoan.interestRate)
        #expect(templeLoan.totalOwed < merchantLoan.totalOwed)
    }

    // MARK: - Guild Tests

    @Test func guildCreation() async throws {
        let guild = Guild.create(
            name: "Test Guild",
            motto: "Testing is power",
            homeRealm: .theEmpire,
            homeRegion: "Central Province",
            tier: .rising,
            isPlayerControlled: true
        )

        #expect(guild.name == "Test Guild")
        #expect(guild.tier == .rising)
        #expect(guild.isPlayerControlled == true)
        #expect(guild.staff.count > 0)
        #expect(guild.council.patrons.count == 5)
    }

    @Test func guildRosterCapacity() async throws {
        let guild = Guild.create(
            name: "Test Guild",
            motto: "Test",
            homeRealm: .theEmpire,
            homeRegion: "Test",
            tier: .fledgling,
            isPlayerControlled: false
        )

        #expect(guild.rosterCapacity > 0)
        #expect(guild.hasRosterSpace == true)
    }

    @Test func guildStaffManagement() async throws {
        let guild = Guild.create(
            name: "Test Guild",
            motto: "Test",
            homeRealm: .theEmpire,
            homeRegion: "Test",
            tier: .fledgling,
            isPlayerControlled: false
        )

        #expect(guild.hasStaff(role: .combatInstructor) == true)
        #expect(guild.hasStaff(role: .healerOnRetainer) == true)
        #expect(guild.hasStaff(role: .secondInCommand) == false)
    }

    @Test func guildWeeklyOperatingCosts() async throws {
        let guild = Guild.create(
            name: "Test Guild",
            motto: "Test",
            homeRealm: .theEmpire,
            homeRegion: "Test",
            tier: .rising,
            isPlayerControlled: false
        )

        #expect(guild.weeklyStaffSalaries > 0)
        #expect(guild.weeklyOperatingCosts > guild.weeklyStaffSalaries)
    }

    @Test func randomAIGuildGeneration() async throws {
        let guild = Guild.randomAI(in: .theFreeCities, tier: .established)

        #expect(!guild.name.isEmpty)
        #expect(guild.homeRealm == .theFreeCities)
        #expect(guild.tier == .established)
        #expect(guild.isPlayerControlled == false)
    }

    // MARK: - Reputation Tests

    @Test func reputationLevelCalculation() async throws {
        var rep = GuildReputation(local: 50, regional: 20, continental: 0)
        #expect(rep.level == .local)

        rep.regional = 60
        #expect(rep.level == .regional)

        rep.continental = 55
        #expect(rep.level == .continental)

        rep.continental = 80
        #expect(rep.level == .legendary)
    }

    // MARK: - Guild Statistics Tests

    @Test func guildStatisticsCalculations() async throws {
        var stats = GuildStatistics()
        stats.totalQuestsCompleted = 80
        stats.totalQuestsFailed = 20
        stats.totalGoldEarned = 50000
        stats.totalGoldSpent = 30000

        #expect(stats.questSuccessRate == 0.8)
        #expect(stats.netProfit == 20000)
    }
}
