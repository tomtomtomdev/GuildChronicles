//
//  Realm.swift
//  GuildChronicles
//
//  Game world realms (Section 4.1)
//

import Foundation

enum RealmTier: Int, Codable, CaseIterable {
    case tier1 = 1  // Full region structure
    case tier2 = 2  // Major + secondary regions
    case tier3 = 3  // Primary region only
}

enum Realm: String, Codable, CaseIterable, Identifiable {
    // Tier 1 Realms (Full Region Structure)
    case theEmpire
    case theNorthernKingdoms
    case theElvenDominion
    case theDwarvenHolds
    case theFreeCities
    case theBorderlands
    case theCoastalConfederacy

    // Tier 2 Realms (Major + Secondary)
    case theDragonWastes
    case theUnderdarkAccessPoints
    case theFeyCourts
    case theOrcSteppes
    case theMerchantRepublic
    case theTheocracyOfTheSun
    case theNecromancersBlight
    case theBarbarianNorthlands
    case theIslandChains
    case theDesertCaliphates

    // Tier 3 Realms (Primary Region Only)
    case theFrozenReaches
    case theJungleKingdoms
    case theVolcanicIsles
    case thePlanarCrossroads
    case theRuinsOfTheAncients
    case theShadowfellBorders
    case theFeywildGates
    case theElementalConvergences
    case theFarRealmsEdge

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .theEmpire: return "The Empire"
        case .theNorthernKingdoms: return "The Northern Kingdoms"
        case .theElvenDominion: return "The Elven Dominion"
        case .theDwarvenHolds: return "The Dwarven Holds"
        case .theFreeCities: return "The Free Cities"
        case .theBorderlands: return "The Borderlands"
        case .theCoastalConfederacy: return "The Coastal Confederacy"
        case .theDragonWastes: return "The Dragon Wastes"
        case .theUnderdarkAccessPoints: return "The Underdark Access Points"
        case .theFeyCourts: return "The Fey Courts"
        case .theOrcSteppes: return "The Orc Steppes"
        case .theMerchantRepublic: return "The Merchant Republic"
        case .theTheocracyOfTheSun: return "The Theocracy of the Sun"
        case .theNecromancersBlight: return "The Necromancer's Blight"
        case .theBarbarianNorthlands: return "The Barbarian Northlands"
        case .theIslandChains: return "The Island Chains"
        case .theDesertCaliphates: return "The Desert Caliphates"
        case .theFrozenReaches: return "The Frozen Reaches"
        case .theJungleKingdoms: return "The Jungle Kingdoms"
        case .theVolcanicIsles: return "The Volcanic Isles"
        case .thePlanarCrossroads: return "The Planar Crossroads"
        case .theRuinsOfTheAncients: return "The Ruins of the Ancients"
        case .theShadowfellBorders: return "The Shadowfell Borders"
        case .theFeywildGates: return "The Feywild Gates"
        case .theElementalConvergences: return "The Elemental Convergences"
        case .theFarRealmsEdge: return "The Far Realms Edge"
        }
    }

    var tier: RealmTier {
        switch self {
        case .theEmpire, .theNorthernKingdoms, .theElvenDominion,
             .theDwarvenHolds, .theFreeCities, .theBorderlands,
             .theCoastalConfederacy:
            return .tier1

        case .theDragonWastes, .theUnderdarkAccessPoints, .theFeyCourts,
             .theOrcSteppes, .theMerchantRepublic, .theTheocracyOfTheSun,
             .theNecromancersBlight, .theBarbarianNorthlands, .theIslandChains,
             .theDesertCaliphates:
            return .tier2

        case .theFrozenReaches, .theJungleKingdoms, .theVolcanicIsles,
             .thePlanarCrossroads, .theRuinsOfTheAncients, .theShadowfellBorders,
             .theFeywildGates, .theElementalConvergences, .theFarRealmsEdge:
            return .tier3
        }
    }

    /// Number of regions in this realm
    var regionCount: Int {
        switch self {
        case .theEmpire: return 6
        case .theNorthernKingdoms: return 4
        case .theElvenDominion: return 3
        case .theDwarvenHolds: return 3
        case .theFreeCities: return 5
        case .theBorderlands: return 4
        case .theCoastalConfederacy: return 3
        default:
            // Tier 2: 2 regions (major + secondary)
            // Tier 3: 1 region (primary only)
            return tier == .tier2 ? 2 : 1
        }
    }
}
