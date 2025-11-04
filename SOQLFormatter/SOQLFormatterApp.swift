//
//  SOQLFormatterApp.swift
//  SOQLFormatter
//
//  Created by Andrew Mugford on 2025-11-04.
//

import SwiftUI
import CoreData

@main
struct SOQLFormatterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
