import Foundation

protocol ResultType {
    
    associatedtype AbstractDataType
    associatedtype AbstractErrorType: Error
    
    func map<OtherData>(
        _ f: (AbstractDataType) -> OtherData
    ) -> Result<OtherData, AbstractErrorType>
    
    func flatMap<OtherData>(
        _ f: (AbstractDataType) -> Result<OtherData, AbstractErrorType>
    ) -> Result<OtherData, AbstractErrorType>
    
}

extension Result: ResultType {}

protocol DeferredType {
    
    associatedtype AbstractDataType
    
    func map<OtherData>(
        _ f: @escaping (AbstractDataType) -> OtherData
    ) -> Deferred<OtherData>
    
    func flatMap<OtherData>(
        _ f: @escaping (AbstractDataType) -> Deferred<OtherData>
    ) -> Deferred<OtherData>
}

extension Deferred: DeferredType {}

protocol ArrayType {
    
    associatedtype AbstractDataType
    
    func map<OtherData>(
        _ f: @escaping (AbstractDataType) throws -> OtherData
    ) rethrows -> [OtherData]
    
    func flatMap<OtherData>(
        _ f: @escaping (AbstractDataType) throws -> [OtherData]
    ) rethrows -> [OtherData]
}

extension Array: ArrayType {
    typealias AbstractDataType = Element
}

protocol OptionalType {
 
    associatedtype AbstractDataType
    
    func map<OtherData>(
        _ f: @escaping (AbstractDataType) throws -> OtherData
    ) rethrows -> OtherData?
    
    func flatMap<OtherData>(
        _ f: @escaping (AbstractDataType) throws -> OtherData?
    ) rethrows -> OtherData?
}

extension Optional: OptionalType {}
