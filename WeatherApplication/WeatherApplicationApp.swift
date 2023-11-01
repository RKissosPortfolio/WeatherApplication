//
//  WeatherApplicationApp.swift
//  WeatherApplication
//
//  Created by Ronnie Kissos on 11/1/23.
//

import SwiftUI

@main
struct WeatherApplicationApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
