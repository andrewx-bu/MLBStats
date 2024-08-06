//  DictionaryMaker.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

typealias HittingStatsDictionary = [Int: HittingStats]
typealias PitchingStatsDictionary = [Int: PitchingStats]
typealias FieldingStatsDictionary = [Int: FieldingStats]

class DictionaryMaker {
    func makeHittingDictionary(hittingStats: [HittingStats]) -> HittingStatsDictionary {
        var dictionary = HittingStatsDictionary()
        for stats in hittingStats {
            dictionary[stats.xMLBAMID] = stats
        }
        return dictionary
    }
    
    func makePitchingDictionary(pitchingStats: [PitchingStats]) -> PitchingStatsDictionary {
        var dictionary = PitchingStatsDictionary()
        for stats in pitchingStats {
            dictionary[stats.xMLBAMID] = stats
        }
        return dictionary
    }
    
    func makeFieldingDictionary(fieldingStats: [FieldingStats]) -> FieldingStatsDictionary {
        var dictionary = FieldingStatsDictionary()
        for stats in fieldingStats {
            dictionary[stats.id] = stats
        }
        return dictionary
    }
}
