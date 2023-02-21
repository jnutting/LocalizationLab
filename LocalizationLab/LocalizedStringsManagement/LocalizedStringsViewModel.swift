//
//  LocalizedStringsViewModel.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-2-2.
//

import Combine
import Foundation

public class LocalizedStringsViewModel: ObservableObject {
    @Published var strings: LocalizedStrings = [:] 

    // A further enhancement here would be to move these values into a configuration object, that is either
    // injected or passed as a parameter to this class.
    private let embeddedStringsFilename = "EmbeddedStrings"
    private let remoteUrl = URL(string: "http://assets.nuthole.com/SampleLocalizedStrings.json")!

    // This should probably be injected
    private let archiver = LocalizedStringsArchiver()

    init() {
        let mergedLocalizedStrings = Publishers.MergeMany(onDeviceStrings(urlForOnDeviceStringsRepository()),
                                                          remoteStrings(remoteUrl))
        mergedLocalizedStrings
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .catch { error in
                // Getting an error here means that either there was an http error or json decoding error.
                // By catching it here, we simply ensure that the local strings (either embedded or cached)
                // are used, instead of the failed remote fetch.
                //
                // Maybe this should be logged to a server or something, to let us know that something
                // is wrong.
                print("Error in fetching or decoding json: \(error)")
                return Empty<LocalizedStrings, Never>()
            }
            .assign(to: &$strings)
    }

    // This is the primary method for reading a localized string. If it doesn't exist in the dictionary,
    // it simply returns the key itself (so at least *something* is displayed)
    func s(_ key: String) -> String {
        strings[key] ?? key
    }

}

private extension LocalizedStringsViewModel {
    func onDeviceStrings(_ url: URL) -> AnyPublisher<LocalizedStrings, LocalizedStringsRepositoryError> {
        return OnDeviceStringsRepository(url: url).localizedStrings()
    }

    func remoteStrings(_ url: URL) -> AnyPublisher<LocalizedStrings, LocalizedStringsRepositoryError> {
        return RemoteStringsRepository(url: url).localizedStrings()
    }

    // If the app contains a previously cached repository from the backend, return the URL for that.
    // Otherwise, return the URL for the json embedded in the app.
    func urlForOnDeviceStringsRepository() -> URL {
        if let url = archiver.cachedStringsUrl() {
            return url
        } else {
            return Bundle.main.url(forResource: embeddedStringsFilename, withExtension: "json")!
        }
    }
}

