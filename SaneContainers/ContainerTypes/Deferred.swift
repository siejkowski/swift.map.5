import Foundation

final class Deferred<DataType> {
    
    enum State {
        case notStarted
        case inProgress
        case done(DataType)
    }
    
    typealias Completion = (DataType) -> ()
    
    typealias Work = (@escaping Completion) -> ()
    
    private let work: Work
    
    private var state: State = .notStarted
    
    private var finishedBlocks: [Completion] = []
    
    init(work: @escaping Work) {
        self.work = work
    }
    
    func run(completion finishBlock: @escaping (DataType) -> ()) {
        switch state {
        case .notStarted:
            state = .inProgress
            finishedBlocks.append(finishBlock)
            work { data in
                self.state = .done(data)
                self.finishedBlocks.forEach { $0(data) }
                self.finishedBlocks.removeAll()
                return
            }
        case .inProgress: finishedBlocks.append(finishBlock)
        case .done(let data): finishBlock(data)
        }
    }
    
    func map<OtherData>(_ f: @escaping (DataType) -> OtherData) -> Deferred<OtherData> {
        return Deferred<OtherData> { completion in
            self.run { data in
                completion(f(data))
            }
        }
    }
    
    func flatMap<OtherData>(_ f: @escaping (DataType) -> Deferred<OtherData>) -> Deferred<OtherData> {
        return Deferred<OtherData> { completion in
            self.run { data in
                f(data).run(completion: completion)
            }
        }
    }
}
