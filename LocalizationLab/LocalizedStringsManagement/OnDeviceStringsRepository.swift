//
//  OnDeviceStringsRepository.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-2-6.
//

import Combine
import Foundation

// This represents a repository of strings held in a local file, either embedded in the app
// or in another on-device directory. The URL given as a parameter is assumed to be read from
// such a file, not from the network, and must therefore be a "file" URL.
// After the results are read from the file and decoded from within the `localizedStrings`
// function, they are output on a Publisher.

struct OnDeviceStringsRepository: LocalizedStringsRepository {
    private let url: URL

    public init(url: URL) {
        assert(url.isFileURL, "Only file URLs are accepted here")
        self.url = url
    }

    public func localizedStrings() -> AnyPublisher<LocalizedStrings, LocalizedStringsRepositoryError> {
        let subject = CurrentValueSubject<LocalizedStrings, LocalizedStringsRepositoryError>([:])

        do {
            let strings: LocalizedStrings = try modelFromJson(url)
            subject.send(strings)
        } catch {
            subject.send(completion: .failure(LocalizedStringsRepositoryError.resourceNotFound(error)))
        }

        return subject
            .eraseToAnyPublisher()
    }
}

extension OnDeviceStringsRepository {
    // Convenience initializer for the case of using a json file that is a known embedded resource.
    init() {
        // Change to `Bundle.module` if this is placed in a module instead of the app
        self.url = Bundle.main.url(forResource: "EmbeddedStrings", withExtension: "json")!
    }
}
