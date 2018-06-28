import Foundation

extension Result {
    
    func mapT<ResultData, ResultError: Error, OtherData>(
        _ f: @escaping (ResultData) -> Result<OtherData, ResultError>
    ) -> Result<Result<OtherData, ResultError>, ErrorType>
    where DataType == Result<ResultData, ResultError> {
        return map { result in result.flatMap(f) }
    }
    
    func mapTT<ResultData, InnerResultError: Error, OtherData>(
        _ f: @escaping (ResultData) -> OtherData
    ) -> Result<Result<[OtherData], InnerResultError>, ErrorType>
    where DataType == Result<[ResultData], InnerResultError> {
        return map { result in result.mapT(f) }
    }
    
    func mapT<ResultData, OtherData>(
        _ f: @escaping (ResultData) -> OtherData
    ) -> Result<[OtherData], ErrorType>
    where DataType == [ResultData] {
        return map { array in array.map(f) }
    }
    
}

extension Deferred {
    
    func mapT<ResultData, ResultError: Error, OtherData>(
        _ f: @escaping (ResultData) -> OtherData
    ) -> Deferred<Result<OtherData, ResultError>>
    where DataType == Result<ResultData, ResultError> {
        return map { result in result.map(f) }
    }
    
    func mapTT<ResultData, InnerResultError: Error, OuterResultError: Error, OtherData>(
        _ f: @escaping (ResultData) -> Result<OtherData, InnerResultError>
    ) -> Deferred<Result<Result<OtherData, InnerResultError>, OuterResultError>>
    where DataType == Result<Result<ResultData, InnerResultError>, OuterResultError> {
        return map { result in result.mapT(f) }
    }
    
    func mapTTT<ResultData, InnerResultError: Error, OuterResultError: Error, OtherData>(
        _ f: @escaping (ResultData) -> OtherData
    ) -> Deferred<Result<Result<[OtherData], InnerResultError>, OuterResultError>>
    where DataType == Result<Result<[ResultData], InnerResultError>, OuterResultError> {
        return map { result in result.mapTT(f) }
    }
    
}
