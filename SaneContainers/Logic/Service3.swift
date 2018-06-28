import Foundation

final class Service3 {
    
    private let session: URLSessionInjectable
    
    init(session: URLSessionInjectable = URLSession.shared) {
        self.session = session
    }
    
    func repoNames(forUser user: String)
        -> Deferred<Result<Result<[String], RepoError>, NetworkAPIError>> {
            
        return Deferred { completion in
            
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
        
        }.mapT { (data: Data) -> Result<[Repo], RepoError> in
            
            do {
                let repo = try JSONDecoder().decode([Repo].self, from: data)
                return .success(repo)
            } catch {
                return .failure(RepoError.cannotDeserializeRepo(reason: error.localizedDescription))
            }
            
        }.mapTT { (repos: [Repo]) -> Result<[Repo], RepoError> in
            
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
            
        }.mapTTT { (repo: Repo) -> String in
            
            return repo.name
        
        }
    }
}
