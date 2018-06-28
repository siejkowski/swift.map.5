import Foundation

enum Result<DataType, ErrorType: Error> {
    case success(DataType)
    case failure(ErrorType)
    
    func unwrap<ResultType>(success successClosure: (DataType) -> ResultType,
                            failure failureClosure: (ErrorType) -> ResultType) -> ResultType {
        switch self {
        case .success(let data): return successClosure(data)
        case .failure(let error): return failureClosure(error)
        }
    }
    
    func map<OtherData>(_ f: (DataType) -> OtherData) -> Result<OtherData, ErrorType> {
        return unwrap(success: { .success(f($0)) },
                      failure: { .failure($0) })
    }
    
    func flatMap<OtherData>(
        _ f: (DataType) -> Result<OtherData, ErrorType>
        ) -> Result<OtherData, ErrorType> {
        return unwrap(success: { f($0) },
                      failure: { .failure($0) })
    }
}
