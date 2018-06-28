import Foundation

let semaphore = DispatchSemaphore(value: 0)
let userName = "SwiftyJSON"

// This is the base version with MADNESS signature
let deferred0 = Service0().repoNames(forUser: userName)

deferred0.run { data in
    print(data)
    semaphore.signal()
}

semaphore.wait()

// This is the version after transforming data model (errors)
let deferred1 = Service1().repoNames(forUser: userName)

deferred1.run { data in
    print(data)
    semaphore.signal()
}

semaphore.wait()

// This is the version after dropping some info (individual deserialization)
let deferred2 = Service2().repoNames(forUser: userName)

deferred2.run { data in
    print(data)
    semaphore.signal()
}

semaphore.wait()

// This is the version using protocol-based transformers (rasures)
let deferred3R = Service3R().repoNames(forUser: userName)

deferred3R.run { data in
    print(data)
    semaphore.signal()
}

semaphore.wait()

// This is the version using method-based transformers
let deferred4 = Service3().repoNames(forUser: userName)

deferred4.run { data in
    print(data)
    semaphore.signal()
}

semaphore.wait()

