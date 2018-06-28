import Foundation

enum NetworkError: Error {
    case wrongURL
    case networkError(reason: String)
    // Many more error cases and intializer to create network error out of dataTask completion block
    init(from error: Error) { self = .networkError(reason: error.localizedDescription) }
}

enum DeserializationError: Error {
    case wrongResponseStructure
    case cannotDeserializeRepo(reason: String)
}

enum ValidationError: Error {
    case unknownLanguage
    case notSwiftyEnough
}

final class Service0 {
        
    private let session: URLSessionInjectable
        
    init(session: URLSessionInjectable = URLSession.shared) {
        self.session = session
    }
    
    func repoNames(forUser user: String)
        -> Deferred<Result<Result<[Result<Result<String, ValidationError>, DeserializationError>], DeserializationError>?, NetworkError>> {
        
        return Deferred<Result<Data?, NetworkError>> { completion in
            
            guard let url = URL(string: "https://api.github.com/users/\(user)/repos") else {
                return completion(.failure(NetworkError.wrongURL))
            }
            
            self.session.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    completion(.failure(NetworkError(from: error)))
                } else {
                    completion(.success(data))
                }
            }.resume()

        }.map { (result: Result<Data?, NetworkError>)
            -> Result<Result<[Result<Repo, DeserializationError>], DeserializationError>?, NetworkError> in

            result.map { maybeData in
                maybeData.map { data -> Result<[Result<Repo, DeserializationError>], DeserializationError> in
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                        let array = json as? [[String: Any]] else {
                        return .failure(DeserializationError.wrongResponseStructure)
                    }
                    
                    let repos = array.map { repoDict -> Result<Repo, DeserializationError> in
                        do {
                            let repoData = try JSONSerialization.data(
                                withJSONObject: repoDict, options: .prettyPrinted
                            )
                            let repo = try JSONDecoder().decode(Repo.self, from: repoData)
                            return .success(repo)
                        } catch {
                            return .failure(DeserializationError.cannotDeserializeRepo(reason: error.localizedDescription))
                        }
                    }
                    
                    return .success(repos)
                }
            }

        }.map { (result: Result<Result<[Result<Repo, DeserializationError>], DeserializationError>?, NetworkError>)
            -> Result<Result<[Result<Result<Repo, ValidationError>, DeserializationError>], DeserializationError>?, NetworkError> in

            result.map { maybeResult in
                maybeResult.map { result in
                    result.map { repos in
                        repos.map { repoResult in
                            repoResult.map { repo in
                                guard let language = repo.language else {
                                    return .failure(ValidationError.unknownLanguage)
                                }
                                if language == "Swift" {
                                    return .success(repo)
                                } else {
                                    return .failure(ValidationError.notSwiftyEnough)
                                }
                            }
                        }
                    }
                }
            }

        }.map { (result: Result<Result<[Result<Result<Repo, ValidationError>, DeserializationError>], DeserializationError>?, NetworkError>)
            -> Result<Result<[Result<Result<String, ValidationError>, DeserializationError>], DeserializationError>?, NetworkError> in

            result.map { maybeResult in
                maybeResult.map { result in
                    result.map { repos in
                        repos.map { repoResult in
                            repoResult.map { repoResult in
                                repoResult.map { repo in
                                    return repo.name
                                }
                            }
                        }
                    }
                }
            }

        }
    }
}
