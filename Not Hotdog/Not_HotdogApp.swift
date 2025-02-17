//
//  Not_HotdogApp.swift
//  Not Hotdog
//
//  Created by Terry Lin on 2/17/25.
//

import SwiftUI

@main
struct Not_HotdogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
