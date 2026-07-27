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

    // displayName assertions require iOS 18 / watchOS 11+ runtime (package platform floor).

    func testRepsStepSetsDisplayNameWithRepCount() throws {
        let dto = WKPlanDTO(
            title: "Upper",
            sportType: "strengthTraining",
            intervals: [
                .repeatSet(reps: 3, intervals: [
                    .init(kind: "reps", reps: 8, name: "Pull-Ups · 25lb", restSec: 90)
                ])
            ]
        )
        let plan = try WorkoutPlanConverter().convert(dto)
        guard case .custom(let workout) = plan.workout else {
            return XCTFail("Expected custom workout")
        }
        XCTAssertEqual(workout.blocks.count, 1)
        XCTAssertEqual(workout.blocks[0].iterations, 3)
        let work = workout.blocks[0].steps.first { $0.purpose == .work }
        XCTAssertEqual(work?.step.displayName, "Pull-Ups · 25lb · 8 reps")
        XCTAssertEqual(workout.blocks[0].steps.filter { $0.purpose == .recovery }.count, 1)
    }

    func testNilRestSecOmitsRecoveryStep() throws {
        let dto = WKPlanDTO(
            title: "Upper",
            sportType: "strengthTraining",
            intervals: [
                .repeatSet(reps: 2, intervals: [
                    .init(kind: "reps", reps: 10, name: "Curl", restSec: nil)
                ])
            ]
        )
        let plan = try WorkoutPlanConverter().convert(dto)
        guard case .custom(let workout) = plan.workout else {
            return XCTFail("Expected custom workout")
        }
        XCTAssertEqual(workout.blocks[0].steps.count, 1)
        XCTAssertEqual(workout.blocks[0].steps[0].purpose, .work)
    }

    func testZeroIterationsThrowsConversionError() throws {
        let dto = WKPlanDTO(
            title: "Bad",
            sportType: "strengthTraining",
            intervals: [
                .repeatSet(reps: 0, intervals: [
                    .init(kind: "reps", reps: 8, name: "Pull-Ups")
                ])
            ]
        )
        XCTAssertThrowsError(try WorkoutPlanConverter().convert(dto)) { error in
            guard case WorkoutPlanConversionError.zeroIterations = error else {
                return XCTFail("Expected zeroIterations, got \(error)")
            }
        }
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

