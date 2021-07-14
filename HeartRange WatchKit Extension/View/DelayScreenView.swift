//
//  DelayScreenView.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/23/21.
//

import SwiftUI
import SwiftUIRouter

struct DelayScreenView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject private var navigator: Navigator
    
    var body: some View {
        ScrollView {
            Text("startDelay.desciption")
            Button("startDelay.1min") {
                appModel.startDelay = 60
                navigator.navigate("/setup")
            }
            Button("startDelay.5min") {
                appModel.startDelay = 60 * 5
                navigator.navigate("/setup")
            }
            Button("startDelay.15min") {
                appModel.startDelay = 60 * 15
                navigator.navigate("/setup")
            }
            Button("startDelay.now") {
                appModel.startDelay = 0
                navigator.navigate("/setup")
            }
            Button("close") {
                navigator.navigate("/setup")
            }
                .padding(.top, 10)
        }
    }
}

struct DelayScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DelayScreenView()
    }
}
