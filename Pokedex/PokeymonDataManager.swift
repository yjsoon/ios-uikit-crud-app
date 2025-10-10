//
//  PokeymonDataManager.swift
//  Pokedex
//
//  Created by Claude Code
//

import Foundation

class PokeymonDataManager {
    static let shared = PokeymonDataManager()

    private let fileManager = FileManager.default
    private let fileName = "pokeymon.json"

    private var fileURL: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }

    private init() {}

    // MARK: - CRUD Operations

    /// Load all Pokeymon from JSON file
    func loadPokeymon() -> [Pokeymon] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let pokeymon = try decoder.decode([Pokeymon].self, from: data)
            return pokeymon
        } catch {
            print("Error loading Pokeymon: \(error)")
            return []
        }
    }

    /// Save all Pokeymon to JSON file
    func savePokeymon(_ pokeymon: [Pokeymon]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(pokeymon)
            try data.write(to: fileURL)
        } catch {
            print("Error saving Pokeymon: \(error)")
        }
    }

    /// Add a new Pokeymon
    func addPokeymon(_ pokeymon: Pokeymon) {
        var allPokeymon = loadPokeymon()
        allPokeymon.append(pokeymon)
        savePokeymon(allPokeymon)
    }

    /// Update an existing Pokeymon
    func updatePokeymon(_ pokeymon: Pokeymon) {
        var allPokeymon = loadPokeymon()
        if let index = allPokeymon.firstIndex(where: { $0.id == pokeymon.id }) {
            allPokeymon[index] = pokeymon
            savePokeymon(allPokeymon)
        }
    }

    /// Delete a Pokeymon
    func deletePokeymon(_ pokeymon: Pokeymon) {
        var allPokeymon = loadPokeymon()
        allPokeymon.removeAll { $0.id == pokeymon.id }
        savePokeymon(allPokeymon)
    }

    /// Delete Pokeymon at specific index
    func deletePokeymon(at index: Int) {
        var allPokeymon = loadPokeymon()
        guard index >= 0 && index < allPokeymon.count else { return }
        allPokeymon.remove(at: index)
        savePokeymon(allPokeymon)
    }
}
