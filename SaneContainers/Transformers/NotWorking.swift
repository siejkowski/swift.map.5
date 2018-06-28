import Foundation

// FIRST FAIL

//extension Deferred
//where DataType == Result {
//
//    func mapInner<OtherData>(
//        _ f: (DataType.T) -> OtherData
//    ) -> Deferred<Result<DataType.T, DataType.E>> {
//
//        return map { result in result.map(f) }
//
//    }
//}


// SECOND FAIL

//extension Deferred
//where DataType == Result<ResultData, ResultError> {
//
//    func mapInner<OtherData>(
//        _ f: (ResultData) -> OtherData
//    ) -> Deferred<Result<ResultData, ResultError>> {
//
//        return map { result in result.map(f) }
//
//    }
//}



// THIRD FAIL

//typealias DeferredResult<ResultData, ResultError> =
//    Deferred<Result<ResultData, ResultError>>
//    where ResultError: Error
//
//extension DeferredResult<ResultData, ResultError> {
//
//    func mapInner<OtherData>(
//        _ f: (ResultData) -> OtherData
//    ) -> DeferredResult<ResultData, ResultError> {
//
//        return map { result in result.map(f) }
//
//    }
//}
