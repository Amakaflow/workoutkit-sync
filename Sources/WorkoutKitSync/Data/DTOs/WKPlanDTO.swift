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
    public let intervals: [Interval]
    /// Mapper SportRouter desired composition (AMA-2350 / AMA-2351).
    public let composition: String
    /// What the DTO body actually encodes (may lag desired until P2/P3).
    public let compositionEffective: String
    /// Machine reason code for preview / telemetry.
    public let routingReason: String
    
    /// Public memberwise initializer
    public init(
        title: String,
        sportType: String,
        schedule: Schedule? = nil,
        intervals: [Interval],
        composition: String = "custom",
        compositionEffective: String? = nil,
        routingReason: String = "legacy_unspecified"
    ) {
        self.title = title
        self.sportType = sportType
        self.schedule = schedule
        self.intervals = intervals
        self.composition = composition
        self.compositionEffective = compositionEffective ?? composition
        self.routingReason = routingReason
    }

    private enum CodingKeys: String, CodingKey {
        case title, sportType, schedule, intervals
        case composition
        case compositionEffective = "composition_effective"
        case routingReason = "routing_reason"
        // Also accept camelCase from some clients
        case compositionEffectiveCamel = "compositionEffective"
        case routingReasonCamel = "routingReason"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        sportType = try container.decode(String.self, forKey: .sportType)
        schedule = try container.decodeIfPresent(Schedule.self, forKey: .schedule)
        intervals = try container.decode([Interval].self, forKey: .intervals)
        composition = try container.decodeIfPresent(String.self, forKey: .composition) ?? "custom"
        if let effective = try container.decodeIfPresent(String.self, forKey: .compositionEffective)
            ?? container.decodeIfPresent(String.self, forKey: .compositionEffectiveCamel) {
            compositionEffective = effective
        } else {
            compositionEffective = composition
        }
        routingReason = try container.decodeIfPresent(String.self, forKey: .routingReason)
            ?? container.decodeIfPresent(String.self, forKey: .routingReasonCamel)
            ?? "legacy_unspecified"
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
            public let kind: String
            public let seconds: Int?
            public let meters: Double?
            public let reps: Int?
            public let name: String?
            public let load: Load?
            public let restSec: Int?
            public let target: Target?
            
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

            private enum CodingKeys: String, CodingKey {
                case kind, seconds, meters, reps, name, load, restSec, target
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                kind = try container.decode(String.self, forKey: .kind)
                seconds = try container.decodeIfPresent(Int.self, forKey: .seconds)
                meters = try container.decodeIfPresent(Double.self, forKey: .meters)
                reps = try container.decodeIfPresent(Int.self, forKey: .reps)
                load = try container.decodeIfPresent(Load.self, forKey: .load)
                restSec = try container.decodeIfPresent(Int.self, forKey: .restSec)

                var resolvedName = try container.decodeIfPresent(String.self, forKey: .name)
                var resolvedTarget: Target?
                if container.contains(.target) {
                    if let structured = try? container.decode(Target.self, forKey: .target) {
                        resolvedTarget = structured
                    } else if let legacyDisplay = try? container.decode(String.self, forKey: .target) {
                        // Pre-cutover mapper put display text in `target`.
                        if resolvedName == nil || resolvedName?.isEmpty == true {
                            resolvedName = legacyDisplay
                        }
                    }
                }
                name = resolvedName
                target = resolvedTarget
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