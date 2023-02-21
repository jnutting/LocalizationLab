//
//  RemoteStringsRepository.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-2-6.
//

import Combine
import Foundation

// This represents a repository of strings that are fetched from a remote URL. After the results
// are fetched and decoded from within the `localizedStrings` function, they are output on a Publisher.

struct RemoteStringsRepository: LocalizedStringsRepository {
    private let url: URL

    // This should probaly be injected
    private let archiver = LocalizedStringsArchiver()

    public init(url: URL) {
        self.url = url
    }

    public func localizedStrings() -> AnyPublisher<LocalizedStrings, LocalizedStringsRepositoryError> {
        let subject = CurrentValueSubject<LocalizedStrings, LocalizedStringsRepositoryError>([:])

        Task {
            do {
                let data = try await load(url: url)
                let strings: LocalizedStrings = try modelFromJson(data)

                try archiver.save(data)
                subject.send(strings)
            } catch {
                subject.send(completion: .failure(LocalizedStringsRepositoryError.resourceNotFound(error)))
            }

        }

        return subject
            .eraseToAnyPublisher()
    }
}

private func load(url: URL) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))

    guard let httpResponse = response as? HTTPURLResponse else {
        // This will never happen, in theory.
        throw LocalizedStringsRepositoryError.invalidHttpResponse
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw LocalizedStringsRepositoryError.httpError(httpResponse.statusCode)
    }

    return data
}

