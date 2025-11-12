#if canImport(XCTest)
import XCTest
@testable import WorkoutKitSync

#if canImport(WorkoutKit) && canImport(HealthKit)
import WorkoutKit
import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
final class WorkoutPlanConverterTests: XCTestCase {

    func testConvertBuildsWarmupBlocksAndCooldown() throws {
        let dto = try makeRunningDTO()
        let converter = WorkoutPlanConverter()

        let plan = try converter.convert(dto)
        guard case .custom(let workout) = plan.workout else {
            return XCTFail("Expected custom workout")
        }

        XCTAssertEqual(workout.displayName, "Sample Workout")
        XCTAssertNotNil(workout.warmup, "Warmup should be populated")
        XCTAssertNotNil(workout.cooldown, "Cooldown should be populated")
        XCTAssertEqual(workout.blocks.count, 2)
        XCTAssertEqual(workout.blocks.first?.iterations, 1)
        XCTAssertEqual(workout.blocks.last?.iterations, 2)
        XCTAssertEqual(workout.blocks.first?.steps.count, 1)
        XCTAssertEqual(workout.blocks.last?.steps.count, 3) // two work steps + recovery
    }

    func testConvertMapsSportTypeToHealthKitActivity() throws {
        let dto = try makeRunningDTO()
        let converter = WorkoutPlanConverter()

        let plan = try converter.convert(dto)
        guard case .custom(let workout) = plan.workout else {
            return XCTFail("Expected custom workout")
        }

        XCTAssertEqual(workout.activity, .running)
    }

    func testStrengthTrainingDistanceStepsFallbackToOpen() throws {
        let dto = try makeStrengthTrainingDTO()
        let converter = WorkoutPlanConverter()

        let plan = try converter.convert(dto)
        guard case .custom(let workout) = plan.workout else {
            return XCTFail("Expected custom workout")
        }

        XCTAssertEqual(workout.activity, .traditionalStrengthTraining)
        XCTAssertEqual(workout.blocks.flatMap(\.steps).count, 2)
    }

    private func makeRunningDTO() throws -> WKPlanDTO {
        let json = """
        {
          "title": "Sample Workout",
          "sportType": "running",
          "intervals": [
            { "kind": "warmup", "seconds": 300 },
            { "kind": "time", "seconds": 60, "name": "Build" },
            {
              "kind": "repeat",
              "reps": 2,
              "intervals": [
                { "kind": "time", "seconds": 45, "name": "Fast" },
                { "kind": "time", "seconds": 30, "restSec": 15, "name": "Slow", "target": { "pace": 3.5 } }
              ]
            },
            { "kind": "cooldown", "seconds": 180 }
          ]
        }
        """
        return try JSONDecoder().decode(WKPlanDTO.self, from: Data(json.utf8))
    }

    private func makeStrengthTrainingDTO() throws -> WKPlanDTO {
        let json = """
        {
          "title": "Strength Workout",
          "sportType": "strengthTraining",
          "intervals": [
            {
              "kind": "repeat",
              "reps": 1,
              "intervals": [
                { "kind": "distance", "meters": 20 },
                { "kind": "reps", "reps": 10, "name": "Push Ups" }
              ]
            }
          ]
        }
        """
        return try JSONDecoder().decode(WKPlanDTO.self, from: Data(json.utf8))
    }
}
#endif
#endif

