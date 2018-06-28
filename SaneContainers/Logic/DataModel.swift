import Foundation

struct Repo: Decodable, CustomDebugStringConvertible {
    
    let name: String
    let language: String?
    
    var debugDescription: String { return name }
}
