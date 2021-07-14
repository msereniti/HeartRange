//
//  RangePickerView.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/18/21.
//

import SwiftUI



struct RangePickerView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        
        let minRange = 30 / 5 ..< max(30 / 5 + 1, appModel.maxHeartRate / 5)
        let minHeartRate = Binding<Int>(
            get: { (self.appModel.minHeartRate) / 5 },
            set: { self.appModel.minHeartRate = $0 * 5 }
        )
        
        let maxRange = min(appModel.minHeartRate / 5 + 1, 200 / 5) ..< 200 / 5 + 1
        let maxHeartRate = Binding<Int>(
            get: { (self.appModel.maxHeartRate) / 5 },
            set: { self.appModel.maxHeartRate = $0 * 5 }
        )
        
        HStack(alignment: .center) {
            Picker("from", selection: minHeartRate) {
                ForEach(minRange, id: \.self) { value in
                    Text("\(value * 5)")
                }
            }.animation(nil)
            Text("-")
                .font(.title2)
            Picker("to", selection: maxHeartRate) {
                ForEach(maxRange, id: \.self) { value in
                    Text("\(value * 5)")
                }
            }.animation(nil)
        }
        .frame(height: 45)
        .font(.title)
        .labelsHidden()
    }
}

struct ScrollPickerView_Previews: PreviewProvider {
    static var previews: some View {
        RangePickerView()
    }
}
