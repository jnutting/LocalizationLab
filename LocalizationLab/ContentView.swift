//
//  ContentView.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-1-31.
//

import SwiftUI

struct ContentView: View {
    // This should be injected; or an environment object; or even just a parameter stored in an @ObservedObject, whatever makes sense in your architecture.
    @StateObject var ls = LocalizedStringsViewModel()

    var body: some View {
        VStack {
            GroupBox("Title") {
                Text(ls.s("titleText"))
            }
            GroupBox("Undefined key") {
                Text(ls.s("undefinedKey"))
            }
            GroupBox("Description") {
                Text(ls.s("descriptionText"))
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
