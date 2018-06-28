import Foundation

extension Result: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .success(let data):
            return "success(\(data))"
        case .failure(let error):
            return "failure(\(error))"
        }
    }
}
