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

    /// Short description of the realm
    var description: String {
        switch self {
        case .theEmpire: return "A vast human empire with diverse regions"
        case .theNorthernKingdoms: return "Independent human kingdoms of the north"
        case .theElvenDominion: return "Ancient elven forests and cities"
        case .theDwarvenHolds: return "Mountain strongholds of the dwarves"
        case .theFreeCities: return "Independent city-states and trade hubs"
        case .theBorderlands: return "Frontier territories between realms"
        case .theCoastalConfederacy: return "Maritime nations and port cities"
        case .theDragonWastes: return "Lands scarred by ancient dragons"
        case .theUnderdarkAccessPoints: return "Surface entries to the deep realms"
        case .theFeyCourts: return "Lands touched by the Feywild"
        case .theOrcSteppes: return "Vast plains ruled by orc tribes"
        case .theMerchantRepublic: return "Wealth-driven trading nation"
        case .theTheocracyOfTheSun: return "Holy lands of the sun priests"
        case .theNecromancersBlight: return "Cursed lands of undeath"
        case .theBarbarianNorthlands: return "Harsh northern tribal territories"
        case .theIslandChains: return "Scattered islands and archipelagos"
        case .theDesertCaliphates: return "Sun-scorched desert kingdoms"
        case .theFrozenReaches: return "Icy wastelands of the far north"
        case .theJungleKingdoms: return "Dense tropical wilderness"
        case .theVolcanicIsles: return "Fire-touched island chains"
        case .thePlanarCrossroads: return "Where planes intersect"
        case .theRuinsOfTheAncients: return "Remnants of fallen civilizations"
        case .theShadowfellBorders: return "Lands touched by shadow"
        case .theFeywildGates: return "Portals to the realm of fey"
        case .theElementalConvergences: return "Where elemental forces collide"
        case .theFarRealmsEdge: return "Border of reality itself"
        }
    }

    /// Primary regions within this realm
    var regions: [String] {
        switch self {
        case .theEmpire:
            return ["Imperial Heartland", "Western Marches", "Eastern Provinces", "Southern Coast", "Northern Frontier", "Imperial Capital"]
        case .theNorthernKingdoms:
            return ["Highland Realm", "Lakeland", "The Northmarch", "Winter's Edge"]
        case .theElvenDominion:
            return ["The Ancient Wood", "Silver Glades", "Starlight Coast"]
        case .theDwarvenHolds:
            return ["The Great Hall", "The Deep Mines", "The Outer Holds"]
        case .theFreeCities:
            return ["Merchant's Rest", "The Harbor", "Crossroads", "The Old Quarter", "New Town"]
        case .theBorderlands:
            return ["The Frontier", "No Man's Land", "The Crossing", "Wild Territories"]
        case .theCoastalConfederacy:
            return ["Port Cities", "The Archipelago", "Coral Coast"]
        default:
            return [displayName]
        }
    }
}
