//
//  WKPlanDTO.swift
//  WorkoutKitSync
//
//  Data Transfer Object for parsing workout plan JSON structure
//

import Foundation

/// Data Transfer Object for workout plan JSON structure
public struct WKPlanDTO: Decodable, Sendable {
    let title: String
    let sportType: String
    let schedule: Schedule?
    let intervals: [Interval]
    
    /// Public memberwise initializer
    public init(title: String, sportType: String, schedule: Schedule? = nil, intervals: [Interval]) {
        self.title = title
        self.sportType = sportType
        self.schedule = schedule
        self.intervals = intervals
    }
    
    public struct Schedule: Decodable, Sendable {
        let startLocal: String?
        
        public init(startLocal: String? = nil) {
            self.startLocal = startLocal
        }
    }
    
    public enum Interval: Decodable, Sendable {
        case warmup(seconds: Int, target: Target?)
        case cooldown(seconds: Int, target: Target?)
        case repeatSet(reps: Int, intervals: [Step])
        case step(Step)
        
        public struct Target: Decodable, Sendable {
            let hrZone: Int?
            let pace: Double?
            
            public init(hrZone: Int? = nil, pace: Double? = nil) {
                self.hrZone = hrZone
                self.pace = pace
            }
        }
        
        public struct Step: Decodable, Sendable {
            let kind: String
            let seconds: Int?
            let meters: Double?
            let reps: Int?
            let name: String?
            let load: Load?
            let restSec: Int?
            let target: Target?
            
            public init(kind: String, seconds: Int? = nil, meters: Double? = nil, reps: Int? = nil, name: String? = nil, load: Load? = nil, restSec: Int? = nil, target: Target? = nil) {
                self.kind = kind
                self.seconds = seconds
                self.meters = meters
                self.reps = reps
                self.name = name
                self.load = load
                self.restSec = restSec
                self.target = target
            }
        }
        
        public struct Load: Decodable, Sendable {
            let value: Double
            let unit: String
            
            public init(value: Double, unit: String) {
                self.value = value
                self.unit = unit
            }
        }
        
        // Custom decoding implementation using a wrapper struct
        private enum CodingKeys: String, CodingKey {
            case kind, seconds, reps, intervals, target
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kindString = try container.decode(String.self, forKey: .kind)
            let kind = IntervalKind(rawValue: kindString)
            
            switch kind {
            case .warmup:
                let seconds = try container.decodeIfPresent(Int.self, forKey: .seconds) ?? 0
                let target = try? container.decodeIfPresent(Target.self, forKey: .target)
                self = .warmup(seconds: seconds, target: target)
                
            case .cooldown:
                let seconds = try container.decodeIfPresent(Int.self, forKey: .seconds) ?? 0
                let target = try? container.decodeIfPresent(Target.self, forKey: .target)
                self = .cooldown(seconds: seconds, target: target)
                
            case .repeatSet:
                let reps = try container.decode(Int.self, forKey: .reps)
                let intervals = try container.decode([Step].self, forKey: .intervals)
                self = .repeatSet(reps: reps, intervals: intervals)
                
            case .reps, .distance, .time, .none:
                // These are step types - decode the entire object as a Step
                let step = try Step(from: decoder)
                self = .step(step)
            }
        }
    }
}