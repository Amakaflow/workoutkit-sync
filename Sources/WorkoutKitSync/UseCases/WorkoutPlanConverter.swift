//
//  WorkoutPlanConverter.swift
//  WorkoutKitSync
//
//  Use Case: Converts DTO to WorkoutKit models
//

#if canImport(WorkoutKit) && canImport(HealthKit) && (os(iOS) || os(watchOS))
import Foundation
import HealthKit
@preconcurrency import WorkoutKit

/// Protocol for converting DTOs into WorkoutKit plans
@available(iOS 18.0, watchOS 11.0, *)
public protocol WorkoutPlanConverterProtocol {
    func convert(_ dto: WKPlanDTO) throws -> WorkoutPlan
}

@available(iOS 18.0, watchOS 11.0, *)
public struct WorkoutPlanConverter: WorkoutPlanConverterProtocol {
    
    public init() {}
    
    public func convert(_ dto: WKPlanDTO) throws -> WorkoutPlan {
        let sportType = SportType(rawValue: dto.sportType) ?? .other
        let activity = sportType.toHealthKitActivityType()
        var custom = CustomWorkout(activity: activity)
        custom.displayName = dto.title
        
        let structure = try buildStructure(from: dto.intervals, sportType: sportType)
        custom.warmup = structure.warmup
        custom.blocks = structure.blocks
        custom.cooldown = structure.cooldown
        
        return WorkoutPlan(.custom(custom))
    }
    
    private func buildStructure(from intervals: [WKPlanDTO.Interval],
                                sportType: SportType) throws -> (warmup: WorkoutStep?, blocks: [IntervalBlock], cooldown: WorkoutStep?) {
        var warmup: WorkoutStep?
        var cooldown: WorkoutStep?
        var blocks: [IntervalBlock] = []
        var currentSteps: [IntervalStep] = []
        
        func flushCurrentSteps() {
            guard !currentSteps.isEmpty else { return }
            blocks.append(IntervalBlock(steps: currentSteps, iterations: 1))
            currentSteps.removeAll()
        }
        
        for interval in intervals {
            switch interval {
            case .warmup(let seconds, let target):
                let step = makeWorkoutStep(goal: .time(Double(seconds), .seconds),
                                           alert: makeAlert(from: target),
                                           displayName: "Warmup")
                if warmup == nil {
                    warmup = step
                } else {
                    currentSteps.append(IntervalStep(.work, step: step))
                }
            case .cooldown(let seconds, let target):
                let step = makeWorkoutStep(goal: .time(Double(seconds), .seconds),
                                           alert: makeAlert(from: target),
                                           displayName: "Cooldown")
                if cooldown == nil {
                    cooldown = step
                } else {
                    currentSteps.append(IntervalStep(.work, step: step))
                }
            case .repeatSet(let repetitions, let steps):
                flushCurrentSteps()
                var intervalSteps: [IntervalStep] = []
                for step in steps {
                    intervalSteps.append(contentsOf: try makeIntervalSteps(from: step, sportType: sportType))
                }
                guard !intervalSteps.isEmpty else { continue }
                var block = IntervalBlock(steps: intervalSteps, iterations: repetitions)
                blocks.append(block)
            case .step(let step):
                currentSteps.append(contentsOf: try makeIntervalSteps(from: step, sportType: sportType))
            }
        }
        
        flushCurrentSteps()
        return (warmup, blocks, cooldown)
    }
    
    private func makeIntervalSteps(from step: WKPlanDTO.Interval.Step,
                                   sportType: SportType) throws -> [IntervalStep] {
        var steps: [IntervalStep] = []
        
        let goal = makeGoal(seconds: step.seconds, meters: step.meters, sportType: sportType)
        let alert = makeAlert(from: step.target)
        let displayName = step.name
        let workStep = makeWorkoutStep(goal: goal, alert: alert, displayName: displayName)
        steps.append(IntervalStep(.work, step: workStep))
        
        if let restSec = step.restSec, restSec > 0 {
            let restGoal: WorkoutGoal = .time(Double(restSec), .seconds)
            let restStep = makeWorkoutStep(goal: restGoal, alert: nil, displayName: "Recovery")
            steps.append(IntervalStep(.recovery, step: restStep))
        }
        
        return steps
    }
    
    private func makeGoal(seconds: Int?, meters: Double?, sportType: SportType) -> WorkoutGoal {
        if let seconds {
            return .time(Double(seconds), .seconds)
        }
        if let meters, sportType.supportsDistanceGoals {
            return .distance(meters, .meters)
        }
        return .open
    }
    
    private func makeAlert(from target: WKPlanDTO.Interval.Target?) -> (any WorkoutAlert)? {
        guard let target = target else { return nil }
        
        if let zone = target.hrZone {
            return HeartRateZoneAlert.heartRate(zone: zone)
        }
        
        if let pace = target.pace {
            return SpeedThresholdAlert.speed(pace, unit: .metersPerSecond, metric: .current)
        }
        
        return nil
    }
    
    private func makeWorkoutStep(goal: WorkoutGoal,
                                 alert: (any WorkoutAlert)?,
                                 displayName: String?) -> WorkoutStep {
        if #available(iOS 18.0, watchOS 11.0, *), let displayName {
            return WorkoutStep(goal: goal, alert: alert, displayName: displayName)
        } else {
            return WorkoutStep(goal: goal, alert: alert)
        }
    }
}
#else
import Foundation

@available(*, unavailable, message: "WorkoutKitSync requires the WorkoutKit framework (iOS 18+/watchOS 11+).")
public protocol WorkoutPlanConverterProtocol {
    func convert(_ dto: WKPlanDTO) throws -> Any
}

@available(*, unavailable, message: "WorkoutKitSync requires the WorkoutKit framework (iOS 18+/watchOS 11+).")
public struct WorkoutPlanConverter: WorkoutPlanConverterProtocol {
    public init() {}
    
    public func convert(_ dto: WKPlanDTO) throws -> Any {
        fatalError("WorkoutKitSync is unavailable without WorkoutKit.")
    }
}
#endif
