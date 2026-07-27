import Foundation

public enum WorkoutPlanConversionError: Error, LocalizedError, Sendable {
    case zeroIterations(exerciseName: String?)
    case emptyBlockSteps(exerciseName: String?)

    public var errorDescription: String? {
        switch self {
        case .zeroIterations(let name):
            return "WorkoutKit interval block has zero iterations\(name.map { " (\($0))" } ?? "")"
        case .emptyBlockSteps(let name):
            return "WorkoutKit interval block has no steps\(name.map { " (\($0))" } ?? "")"
        }
    }
}
