//
//  model.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/15/21.
//

import Foundation
import Combine

class AppModel: ObservableObject {
    @Published(key: "app.model.minHeartRate") var minHeartRate = 130
    @Published(key: "app.model.maxHeartRate") var maxHeartRate = 160
    @Published(key: "app.model.startDelay") var startDelay = 0
}



private var cancellables = [String:AnyCancellable]()

extension Published {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}
