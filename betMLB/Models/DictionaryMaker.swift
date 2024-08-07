//  DictionaryMaker.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

typealias HittingStatsDictionary = [Int: HittingStats]
typealias PitchingStatsDictionary = [Int: PitchingStats]
typealias FieldingStatsDictionary = [Int: FieldingStats]

protocol IdentifiableStat: Identifiable {
    var id: Int { get }
    var teamid: Int { get }
}

// Create a generic dictionary maker
class DictionaryMaker {
    func makeDictionary<T: IdentifiableStat>(stats: [T], useTeamId: Bool = false) -> [Int: T] {
        var dictionary = [Int: T]()
        for stat in stats {
            let key = useTeamId ? stat.teamid : stat.id
            dictionary[key] = stat
        }
        return dictionary
    }
    
    func makePlayerHittingDictionary(hittingStats: [HittingStats]) -> [Int: HittingStats] {
        return makeDictionary(stats: hittingStats)
    }
    
    func makePlayerPitchingDictionary(pitchingStats: [PitchingStats]) -> [Int: PitchingStats] {
        return makeDictionary(stats: pitchingStats)
    }
    
    func makePlayerFieldingDictionary(fieldingStats: [FieldingStats]) -> [Int: FieldingStats] {
        return makeDictionary(stats: fieldingStats)
    }
    
    func makeTeamHittingDictionary(hittingStats: [HittingStats]) -> [Int: HittingStats] {
        return makeDictionary(stats: hittingStats, useTeamId: true)
    }
    
    func makeTeamPitchingDictionary(pitchingStats: [PitchingStats]) -> [Int: PitchingStats] {
        return makeDictionary(stats: pitchingStats, useTeamId: true)
    }
    
    func makeTeamFieldingDictionary(fieldingStats: [FieldingStats]) -> [Int: FieldingStats] {
        return makeDictionary(stats: fieldingStats, useTeamId: true)
    }
}
