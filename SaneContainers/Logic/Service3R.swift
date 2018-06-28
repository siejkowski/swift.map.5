import Foundation

final class Service3R {
    
    private let session: URLSessionInjectable
    
    init(session: URLSessionInjectable = URLSession.shared) {
        self.session = session
    }
    
    func repoNames(forUser user: String)
        -> Deferred<Result<Result<[String], RepoError>, NetworkAPIError>> {
            
            return Deferred<Result<Data, NetworkAPIError>> { completion in
                
                guard let url = URL(string: "https://api.github.com/users/\(user)/repos") else {
                    return completion(.failure(NetworkAPIError.wrongURL))
                }
                
                self.session.dataTask(with: url) { (data, _, error) in
                    if let error = error {
                        completion(.failure(NetworkAPIError(from: error)))
                    } else if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(NetworkAPIError.lackOfData))
                    }
                }.resume()
                
                }.mapR { (data: Data) -> Result<[Repo], RepoError> in
                    do {
                        let repo = try JSONDecoder().decode([Repo].self, from: data)
                        return .success(repo)
                    } catch {
                        return .failure(RepoError.cannotDeserializeRepo(reason: error.localizedDescription))
                    }
                }.mapRR { (repos: [Repo]) -> Result<[Repo], RepoError> in
                    let possibleError = repos.map { elem -> RepoError? in
                        guard let language = elem.language else {
                            return .unknownLanguage
                        }
                        guard language == "Swift" else {
                            return .notSwiftyEnough
                        }
                        return nil
                        }.compactMap { $0 }.first
                    if let error = possibleError {
                        return .failure(error)
                    } else {
                        return .success(repos)
                    }
                }.mapRRR { (repo: Repo) -> String in
                    return repo.name
            }
    }
}
