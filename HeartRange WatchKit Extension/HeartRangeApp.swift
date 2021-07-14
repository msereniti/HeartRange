//
//  HeartRangeApp.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/14/21.
//

import SwiftUI

@main
struct HeartRangeApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
