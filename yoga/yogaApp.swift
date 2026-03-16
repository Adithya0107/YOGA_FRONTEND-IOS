//
//  yogaApp.swift
//  yoga
//
//  Created by Aditya on 24/02/26.
//

import SwiftUI

@main
struct yogaApp: App {
    @AppStorage("darkMode") private var darkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
