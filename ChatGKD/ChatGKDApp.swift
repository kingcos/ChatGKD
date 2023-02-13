//
//  ChatGKDApp.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import SwiftUI

@main
struct ChatGKDApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
