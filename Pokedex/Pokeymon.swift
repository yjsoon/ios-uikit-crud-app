//
//  Pokeymon.swift
//  Pokedex
//
//  Created by Claude Code
//

import Foundation

enum PokeymonType: String, Codable, CaseIterable {
    case fire
    case water
    case earth
    case grass
    case electric
    case ice
    case flying
    case psychic

    var emoji: String {
        switch self {
        case .fire: return "🔥"
        case .water: return "💧"
        case .earth: return "🪨"
        case .grass: return "🌿"
        case .electric: return "⚡️"
        case .ice: return "❄️"
        case .flying: return "🪽"
        case .psychic: return "🔮"
        }
    }
}

struct Pokeymon: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: PokeymonType
    var attack: Int
    var defense: Int
    var dateCaptured: Date

    init(id: UUID = UUID(), name: String, type: PokeymonType, attack: Int, defense: Int, dateCaptured: Date = Date()) {
        self.id = id
        self.name = name
        self.type = type
        self.attack = attack
        self.defense = defense
        self.dateCaptured = dateCaptured
    }
}
