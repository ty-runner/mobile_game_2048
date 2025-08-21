//
//  CloudKitManager.swift
//  mobile_game_2048
//
//  Created by Cameron McClymont on 8/16/25.
//

import CloudKit

// Cloud record keys
private enum CKKeys {
    static let recordType = "PlayerData"
    static let recordName = "playerData"                 // one-per-user in Private DB
    static let highScore = "highscore"                    // Int(64)
    static let coins = "coins"                            // Int(64)
    static let backgroundsUnlocked = "backgroundsUnlocked"// Int(64) List
    static let lastUpdated = "LastLogin"                // Date
}

final class CloudKitManager {
    static let shared = CloudKitManager()
    private init() {}

    private let db = CKContainer(identifier: "iCloud.com.QuantumLabs.Casc8ded").privateCloudDatabase

    // Fetch or create the single PlayerStats record
    private func fetchOrCreateRecord() async throws -> CKRecord {
        let id = CKRecord.ID(recordName: CKKeys.recordName)
        do {
            return try await db.record(for: id)
        } catch {
            // Not found → create new with defaults
            let rec = CKRecord(recordType: CKKeys.recordType, recordID: id)
            rec[CKKeys.highScore] = 0 as CKRecordValue
            rec[CKKeys.coins] = 0 as CKRecordValue
            rec[CKKeys.backgroundsUnlocked] = [] as CKRecordValue
            rec[CKKeys.lastUpdated] = Date() as CKRecordValue
            let saved = try await db.save(rec)
            return saved
        }
    }

    // Load PlayerStats into your in-memory GameData
    func loadStatsIntoGameData() async throws {
        let rec = try await fetchOrCreateRecord()
        let highScore = (rec[CKKeys.highScore] as? Int) ?? 0
        let coins = (rec[CKKeys.coins] as? Int) ?? 0
        let unlocked = (rec[CKKeys.backgroundsUnlocked] as? [Int]) ?? []

        await MainActor.run {
            GameData.shared.highscore = highScore
            GameData.shared.coins = coins
            GameData.shared.unlockedFeatures = Set(unlocked)
        }
    }

    // Save whole snapshot from GameData (conflict-tolerant)
    func saveAllFromGameData() async {
        do {
            let rec = try await fetchOrCreateRecord()

            // Merge strategy:
            // - Keep MAX highScore
            // - Keep LOCAL coins (your client is source of truth)
            // - UNION backgroundsUnlocked
            let serverHigh = (rec[CKKeys.highScore] as? Int) ?? 0
            let serverUnlocked = (rec[CKKeys.backgroundsUnlocked] as? [Int]) ?? []

            let mergedHigh = max(serverHigh, GameData.shared.highscore)
            let mergedUnlocked = Array(Set(serverUnlocked).union(GameData.shared.unlockedFeatures))

            rec[CKKeys.highScore] = mergedHigh as CKRecordValue
            rec[CKKeys.coins] = GameData.shared.coins as CKRecordValue
            rec[CKKeys.backgroundsUnlocked] = mergedUnlocked as CKRecordValue
            rec[CKKeys.lastUpdated] = Date() as CKRecordValue

            _ = try await db.save(rec)
        } catch {
            print("⚠️ Cloud save failed: \(error)")
        }
    }

    // Convenience partial saves to avoid race-y reads
    func updateCoins(by delta: Int) async {
        await MainActor.run { GameData.shared.coins += delta }
        await saveAllFromGameData()
    }

    func setNoAds(_ value: Bool) async {
        await MainActor.run { GameData.shared.hasNoAds = value }
        // NoAds is local-only in this example. If you want, add it to the record too.
    }

    func addUnlocked(index: Int) async {
        _ = await MainActor.run {
                GameData.shared.unlockedFeatures.insert(index)
            }
        await saveAllFromGameData()
    }

    func updateHighScoreIfNeeded(_ newScore: Int) async {
        let shouldSave = await MainActor.run { () -> Bool in
            if newScore > GameData.shared.highscore {
                GameData.shared.highscore = newScore
                return true
            }
            return false
        }
        if shouldSave {
            await saveAllFromGameData()
        }
    }
}
