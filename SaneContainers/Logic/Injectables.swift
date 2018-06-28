import Foundation

protocol URLSessionTaskInjectable {
    func resume()
}

extension URLSessionTask: URLSessionTaskInjectable {}

protocol URLSessionInjectable {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskInjectable
}

extension URLSession: URLSessionInjectable {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskInjectable {
        let task: URLSessionDataTask = dataTask(with: url,
                                                completionHandler: completionHandler)
        return task
    }
}
