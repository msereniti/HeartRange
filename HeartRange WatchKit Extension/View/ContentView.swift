//
//  ContentView.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/14/21.
//

import SwiftUI
import SwiftUIRouter

struct ContentView: View {
    @StateObject var appModel = AppModel()
    @EnvironmentObject private var navigator: Navigator

    var body: some View {
        Router {
            SwitchRoutes {
                Route(path: "setup") {
                    SetupScreenView()
                }
                Route(path: "recommendation") {
                    RecommendationScreenView()
                }
                Route(path: "delay") {
                    DelayScreenView()
                }
                Route(path: "workout") {
                    WorkoutScreenView()
                }
                Route() {
                    SetupScreenView()
                }
            }  
            .navigationTransition()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
