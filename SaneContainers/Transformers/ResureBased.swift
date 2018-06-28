import Foundation

extension ResultType where AbstractDataType: ArrayType {
    func mapR<OtherData>(
        _ f: @escaping (AbstractDataType.AbstractDataType) -> OtherData
    ) -> Result<[OtherData], AbstractErrorType> {
        return map { array in array.map(f) }
    }
}

extension ResultType where AbstractDataType: ResultType {
    func mapR<OtherData>(
        _ f: @escaping (AbstractDataType.AbstractDataType) -> Result<OtherData, AbstractDataType.AbstractErrorType>
    ) -> Result<Result<OtherData, AbstractDataType.AbstractErrorType>, AbstractErrorType> {
        return map { result in result.flatMap(f) }
    }
}

extension ResultType where AbstractDataType: ResultType, AbstractDataType.AbstractDataType: ArrayType {
    func mapRR<OtherData>(
        _ f: @escaping (AbstractDataType.AbstractDataType.AbstractDataType) -> OtherData
    ) -> Result<Result<[OtherData], AbstractDataType.AbstractErrorType>, AbstractErrorType>{
        return map { result in result.mapR(f) }
    }
}

extension DeferredType where AbstractDataType: ResultType {
    func mapR<OtherData>(
        _ f: @escaping (AbstractDataType.AbstractDataType) -> OtherData
    ) -> Deferred<Result<OtherData, AbstractDataType.AbstractErrorType>> {
        return map { result in result.map(f) }
    }
}

extension DeferredType where AbstractDataType: ResultType, AbstractDataType.AbstractDataType: ResultType {
    func mapRR<OtherData>(
        _ f: @escaping (AbstractDataType.AbstractDataType.AbstractDataType) -> Result<OtherData, AbstractDataType.AbstractDataType.AbstractErrorType>
    ) -> Deferred<Result<Result<OtherData, AbstractDataType.AbstractDataType.AbstractErrorType>, AbstractDataType.AbstractErrorType>>{
        return map { result in result.mapR(f) }
    }
}

extension DeferredType
    where AbstractDataType: ResultType,
          AbstractDataType.AbstractDataType: ResultType,
          AbstractDataType.AbstractDataType.AbstractDataType: ArrayType
{
    
    func mapRRR<OtherData>(
        _ f: @escaping (AbstractDataType.AbstractDataType.AbstractDataType.AbstractDataType) -> OtherData
    ) -> Deferred<Result<Result<[OtherData], AbstractDataType.AbstractDataType.AbstractErrorType>, AbstractDataType.AbstractErrorType>>{
        return map { result in result.mapRR(f) }
    }
}
