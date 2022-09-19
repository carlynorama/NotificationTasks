//
//  NotificationTasksApp.swift
//  NotificationTasks
//
//  Created by Labtanza on 9/13/22.
//

import SwiftUI

enum Services {
    static var flavorManager = FlavorManager()
}

@main
struct NotificationTasksApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }.onChange(of: scenePhase) { newPhase in
            Task { await Services.flavorManager.updateMode(scenePhase: newPhase) }
        }
    }
}
