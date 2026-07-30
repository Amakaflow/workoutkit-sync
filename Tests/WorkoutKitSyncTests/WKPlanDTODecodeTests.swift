#if canImport(XCTest)
import XCTest
@testable import WorkoutKitSync

/// AMA-2351 — composition fields default when absent; unknown-tolerant decode.
final class WKPlanDTODecodeTests: XCTestCase {

    func testMissingCompositionDefaultsToCustom() throws {
        let json = """
        {
          "title": "Legacy",
          "sportType": "running",
          "intervals": [{ "kind": "time", "seconds": 60, "name": "Easy" }]
        }
        """
        let dto = try JSONDecoder().decode(WKPlanDTO.self, from: Data(json.utf8))
        XCTAssertEqual(dto.composition, "custom")
        XCTAssertEqual(dto.compositionEffective, "custom")
        XCTAssertEqual(dto.routingReason, "legacy_unspecified")
    }

    func testSnakeCaseCompositionFieldsDecode() throws {
        let json = """
        {
          "title": "Mapper",
          "sportType": "strengthTraining",
          "composition": "custom",
          "composition_effective": "custom",
          "routing_reason": "strength_sets",
          "intervals": [{ "kind": "reps", "reps": 10, "name": "Squat" }]
        }
        """
        let dto = try JSONDecoder().decode(WKPlanDTO.self, from: Data(json.utf8))
        XCTAssertEqual(dto.composition, "custom")
        XCTAssertEqual(dto.compositionEffective, "custom")
        XCTAssertEqual(dto.routingReason, "strength_sets")
    }

    func testRestStepDecodesWithSeconds() throws {
        let json = """
        {
          "title": "Rest",
          "sportType": "strengthTraining",
          "intervals": [
            { "kind": "rest", "seconds": 45, "name": "Rest" },
            { "kind": "rest", "name": "Tap Rest" }
          ]
        }
        """
        let dto = try JSONDecoder().decode(WKPlanDTO.self, from: Data(json.utf8))
        guard case .step(let timed) = dto.intervals[0] else {
            return XCTFail("expected timed rest step")
        }
        XCTAssertEqual(timed.kind, "rest")
        XCTAssertEqual(timed.seconds, 45)
        guard case .step(let tap) = dto.intervals[1] else {
            return XCTFail("expected tap rest step")
        }
        XCTAssertEqual(tap.kind, "rest")
        XCTAssertNil(tap.seconds)
    }

    func testStringTargetDoesNotCrashDecode() throws {
        // Pre-AMA-2351 mapper put display names in `target` as a string.
        let json = """
        {
          "title": "Legacy target string",
          "sportType": "running",
          "intervals": [
            { "kind": "time", "seconds": 60, "target": "Burpees" }
          ]
        }
        """
        let dto = try JSONDecoder().decode(WKPlanDTO.self, from: Data(json.utf8))
        guard case .step(let step) = dto.intervals[0] else {
            return XCTFail("expected step")
        }
        XCTAssertEqual(step.name, "Burpees")
        XCTAssertNil(step.target)
    }
}
#endif
