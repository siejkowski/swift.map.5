import Foundation

enum RepoError: Error {
    case cannotDeserializeRepo(reason: String)
    case wrongResponseStructure
    case unknownLanguage
    case notSwiftyEnough
}

enum NetworkAPIError: Error {
    case wrongURL
    case networkError(reason: String)
    case lackOfData // the (nil, nil) case
    init(from error: Error) { self = .networkError(reason: error.localizedDescription) }
}

final class Service1 {
    
    private let session: URLSessionInjectable
    
    init(session: URLSessionInjectable = URLSession.shared) {
        self.session = session
    }
    
    func repoNames(forUser user: String)
        -> Deferred<Result<Result<[Result<String, RepoError>], RepoError>, NetworkAPIError>> {
            
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
        }.map { (result: Result<Data, NetworkAPIError>)
            -> Result<Result<[Result<Repo, RepoError>], RepoError>, NetworkAPIError> in
            result.map { data -> Result<[Result<Repo, RepoError>], RepoError> in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let array = json as? [[String: Any]] else {
                        return .failure(RepoError.wrongResponseStructure)
                }
                
                let repos = array.map { repoDict -> Result<Repo, RepoError> in
                    do {
                        let repoData = try JSONSerialization.data(
                            withJSONObject: repoDict, options: .prettyPrinted
                        )
                        let repo = try JSONDecoder().decode(Repo.self, from: repoData)
                        return .success(repo)
                    } catch {
                        return .failure(RepoError.cannotDeserializeRepo(reason: error.localizedDescription))
                    }
                }
                
                return .success(repos)
            }
        }.map { (result: Result<Result<[Result<Repo, RepoError>], RepoError>, NetworkAPIError>)
            -> Result<Result<[Result<Repo, RepoError>], RepoError>, NetworkAPIError> in
            result.map { result in
                result.map { repos in
                    repos.map { (repoResult: Result<Repo, RepoError>) in
                        repoResult.flatMap { repo in
                            guard let language = repo.language else {
                                return .failure(RepoError.unknownLanguage)
                            }
                            if language == "Swift" {
                                return .success(repo)
                            } else {
                                return .failure(RepoError.notSwiftyEnough)
                            }
                        }
                    }
                }
            }
        }.map { (result: Result<Result<[Result<Repo, RepoError>], RepoError>, NetworkAPIError>)
            -> Result<Result<[Result<String, RepoError>], RepoError>, NetworkAPIError> in
            result.map { result in
                result.map { repos in
                    repos.map { repoResult in
                        repoResult.map { repo in
                            return repo.name
                        }
                    }
                }
            }
        }
    }
}
