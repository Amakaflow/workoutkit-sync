//
//  WorkoutPlanService.swift
//  WorkoutKitSync
//
//  Service layer for orchestrating workout plan operations
//

#if canImport(WorkoutKit) && canImport(HealthKit) && (os(iOS) || os(watchOS))
import Foundation
import HealthKit
@preconcurrency import WorkoutKit

@available(iOS 17.0, watchOS 10.0, *)
extension WorkoutScheduler.AuthorizationState: @unchecked Sendable {}

/// Protocol for workout plan service operations
@available(iOS 18.0, watchOS 11.0, *)
@MainActor
public protocol WorkoutPlanServiceProtocol {
    func save(_ dto: WKPlanDTO, scheduleAt dateComponents: DateComponents?) async throws
    func parse(from jsonData: Data) throws -> WKPlanDTO
    func parse(from jsonString: String) throws -> WKPlanDTO
}

/// Service for managing workout plan operations
@available(iOS 18.0, watchOS 11.0, *)
@MainActor
public struct WorkoutPlanService: WorkoutPlanServiceProtocol {
    
    private let converter: WorkoutPlanConverterProtocol
    private let schedulerProvider: () -> WorkoutScheduler
    private let calendar: Calendar
    
    /// Initialize with custom converter and scheduler
    public init(
        converter: WorkoutPlanConverterProtocol = WorkoutPlanConverter(),
        schedulerProvider: @escaping () -> WorkoutScheduler = { WorkoutScheduler.shared },
        calendar: Calendar = .current
    ) {
        self.converter = converter
        self.schedulerProvider = schedulerProvider
        self.calendar = calendar
    }
    
    /// Converts and schedules a workout plan in WorkoutKit
    public func save(_ dto: WKPlanDTO, scheduleAt dateComponents: DateComponents? = nil) async throws {
        let plan = try converter.convert(dto)
        let scheduledDate = dateComponents ?? defaultScheduleDateComponents()
        let scheduler = schedulerProvider()
        try await ensureAuthorization(using: scheduler)
        // Follow-up AMA-2329: WorkoutComposition export / AirDrop .workout share
        await scheduler.schedule(plan, at: scheduledDate)
    }
    
    /// Parses JSON data into a DTO
    public func parse(from jsonData: Data) throws -> WKPlanDTO {
        let decoder = JSONDecoder()
        return try decoder.decode(WKPlanDTO.self, from: jsonData)
    }
    
    /// Parses JSON string into a DTO
    public func parse(from jsonString: String) throws -> WKPlanDTO {
        guard let data = jsonString.data(using: .utf8) else {
            throw WorkoutPlanError.invalidJSONString
        }
        return try parse(from: data)
    }
    
    private func ensureAuthorization(using scheduler: WorkoutScheduler) async throws {
        let currentState = await scheduler.authorizationState
        if currentState != .authorized {
            let result = await scheduler.requestAuthorization()
            guard result == .authorized else {
                throw WorkoutPlanError.authorizationDenied
            }
        }
    }
    
    private func defaultScheduleDateComponents() -> DateComponents {
        let now = Date()
        return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
    }
}
#else
import Foundation

@MainActor
public protocol WorkoutPlanServiceProtocol {
    func save(_ dto: WKPlanDTO, scheduleAt dateComponents: DateComponents?) async throws
    func parse(from jsonData: Data) throws -> WKPlanDTO
    func parse(from jsonString: String) throws -> WKPlanDTO
}

@available(*, unavailable, message: "WorkoutKitSync requires the WorkoutKit framework (iOS 18+/watchOS 11+).")
@MainActor
public struct WorkoutPlanService: WorkoutPlanServiceProtocol {
    public init(converter: WorkoutPlanConverterProtocol = WorkoutPlanConverter()) {}
    
    public func save(_ dto: WKPlanDTO, scheduleAt dateComponents: DateComponents?) async throws {
        fatalError("WorkoutKitSync is unavailable without WorkoutKit.")
    }
    
    public func parse(from jsonData: Data) throws -> WKPlanDTO {
        fatalError("WorkoutKitSync is unavailable without WorkoutKit.")
    }
    
    public func parse(from jsonString: String) throws -> WKPlanDTO {
        fatalError("WorkoutKitSync is unavailable without WorkoutKit.")
    }
}
#endif

/// Errors that can occur during workout plan operations
public enum WorkoutPlanError: Error, LocalizedError {
    case invalidJSONString
    case parsingFailed(Error)
    case conversionFailed(Error)
    case authorizationDenied
    case saveFailed(Error)
    public var errorDescription: String? {
        switch self {
        case .invalidJSONString:
            return "Invalid JSON string format"
        case .parsingFailed(let error):
            return "Failed to parse JSON: \(error.localizedDescription)"
        case .conversionFailed(let error):
            return "Failed to convert DTO: \(error.localizedDescription)"
        case .authorizationDenied:
            return "WorkoutKit authorization was not granted"
        case .saveFailed(let error):
            return "Failed to save workout plan: \(error.localizedDescription)"
        }
    }
}
