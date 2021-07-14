//
//  WorkoutScreenView.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/14/21.
//

import SwiftUI
import SwiftUIRouter
import HealthKit
import AlertKit

struct WorkoutScreenView: View {
    private let healthStore = HKHealthStore()
    private let heartRateQuantity = HKUnit(from: "count/min")
    @State private var query: HKAnchoredObjectQuery? = nil
    
    @State var heartRate = 0
    @State var heartRateMeasured = Date(timeIntervalSince1970: 0)
    @State var measured = false
    
    // used to rerender last measured text
    @State private var now = Date()
    @State var timerFrequency = 1
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var rangeEditVisible = false
    
    @State private var session = WKExtendedRuntimeSession()
    @State private var sessionStartTime = Date(timeIntervalSince1970: 0)
    @SceneStorage("app.permission_was_granted") private var permission_was_sometime_granted = false
    
    @State private var workoutStartTime = Date(timeIntervalSince1970: 0)
    
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var appModel: AppModel
    
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    VStack{
                        HStack {
                            Spacer()
                            HStack {
                                Text("\(appModel.minHeartRate)")
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text("-")
                                Text("\(appModel.maxHeartRate)")
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            }
                            .onTapGesture(perform: {
                                withAnimation {
                                    rangeEditVisible = true
                                }
                            })
                            Spacer()
                            Image(systemName: "heart.circle")
                                .imageScale(.large)
                                .opacity(Date().timeIntervalSince1970 - self.heartRateMeasured.timeIntervalSince1970 < 6 ? 1 : 0.7)
                                .animation(.easeInOut(duration: 0.3))
                                .pulsating(active: Date().timeIntervalSince1970 - self.heartRateMeasured.timeIntervalSince1970 < 6, speed: Double(heartRate))
                            Spacer()
                        }
                        ZStack {
                            HStack{
                                Spacer()
                                VStack{
                                    Text("heartRate")
                                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.trailing, heartRate >= 100 ? 5 : 20)
                                Text("\(heartRate)")
                                    .fontWeight(.black)
                                    .font(.system(size: 40))
                                    .foregroundColor(getHeartRateColor())
                                Spacer()
                            }
                            .opacity(measured ? 1 : 0)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
                            .id("HeartRateValue\(heartRate)")
                            
                            if (!measured) {
                                ActivityIndicator()
                            }
                        }
                        
                        HStack(spacing: 2) {
                            if (now.timeIntervalSince1970 < workoutStartTime.timeIntervalSince1970) {
                                if (workoutStartTime.timeIntervalSince1970 - Date().timeIntervalSince1970 > 90) {
                                    Text("workoutStartsIn.min \(Int((workoutStartTime.timeIntervalSince1970 - Date().timeIntervalSince1970) / 60) + 1)")
                                } else {
                                    Text("workoutStartsIn.s \(Int(workoutStartTime.timeIntervalSince1970 - Date().timeIntervalSince1970))")
                                }
                            } else if (measured) {
                            Text("timeInterval.got")
                                .fontWeight(.thin)
                                .foregroundColor(Color.gray)
                                .font(.footnote)
                            Text(Date().getElapsedInterval(from: heartRateMeasured, to: now))
                                .fontWeight(.thin)
                                .foregroundColor(Color.gray)
                                .font(.footnote)
                            Text("timeInterval.ago")
                                .fontWeight(.thin)
                                .foregroundColor(Color.gray)
                                .font(.footnote)
                            } else {
                                Text("measuring")
                                    .fontWeight(.thin)
                                    .foregroundColor(Color.gray)
                                    .font(.footnote)
                            }
                        }
                        .onReceive(timer) { time in
                            self.now = time
                            
                            if (workoutStartTime.timeIntervalSince1970 > Date().timeIntervalSince1970) {
                                if (timerFrequency != 1) {
                                    timerFrequency = 1
                                    timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                                }
                            } else {
                                if (timerFrequency != 10) {
                                    timerFrequency = 10
                                    timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
                                }
                            }

                            
                            if (sessionStartTime.timeIntervalSince1970 != 0 && Date().timeIntervalSince1970 + 20 * 60.0 > sessionStartTime.timeIntervalSince1970 + 60 * 60.0) {
                                if (session.state == .running) {
                                    session.invalidate()
                                }
                                
                                session = WKExtendedRuntimeSession()
                                session.start()
                                sessionStartTime = Date()
                            }
                            
                            
                        }
                    }
                        .padding(.vertical, 10)
                        .onLongPressGesture {
                            withAnimation {
                                rangeEditVisible = true
                            }
                        }
                        .gesture(TapGesture(count: 2).onEnded {
                            withAnimation {
                                rangeEditVisible = true
                            }
                        })
                    Group {
                        if (workoutStartTime.timeIntervalSince1970 > Date().timeIntervalSince1970) {
                            Button(action: {
                                workoutStartTime = Date(timeIntervalSinceNow: -1)
                                now = Date()
                            }, label: {
                                Text("dismissDelay")
                            })
                        } else {
                            NavLink(to: "/setup") {
                                Text("endWorkout")
                            }
                        }
                    }
                    .foregroundColor(.green)
                }
                .opacity(rangeEditVisible ? 0.1 : 1)
                
                if (rangeEditVisible) {
                    VStack {
                        RangePickerView()
                        Button("close", action: {
                            withAnimation {
                                rangeEditVisible = false
                            }
                        })
                    }
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                }
            }
        }
            .uses(alertManager)
            .onAppear {
                if (appModel.startDelay == 0) {
                    workoutStartTime = Date(timeIntervalSinceNow: -1)
                } else {
                    workoutStartTime = Date(timeIntervalSinceNow: Double(appModel.startDelay))
                }
                
                if (session.state == .running) {
                    session.invalidate()
                }
                
                session = WKExtendedRuntimeSession()
                session.start()
                sessionStartTime = Date()
                
                let healthKitType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
                let readPermissionTypes: Set = [healthKitType]
                
                healthStore.requestAuthorization(toShare: [], read: readPermissionTypes) { (success, error) in
                    if !success {
                        alertManager.show(dismiss: .success(title: String.localizedString(for: "error"), message: error?.localizedDescription ?? String.localizedString(for: "unknownError")))
                  } else {
                        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
                        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                            query, samples, deletedObjects, queryAnchor, error in
                            
                            if (error != nil) {
                                alertManager.show(dismiss: .success(title: String.localizedString(for: "error"), message: error?.localizedDescription ?? String.localizedString(for: "unknownError")))
                           }
                            
                            guard let samples = samples as? [HKQuantitySample] else {
                                return
                            }
                            
                            var lastHeartRate = 0.0
                            
                            for sample in samples {
                                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                            }
                            
                            if (lastHeartRate != 0) {
                                heartRate = Int(lastHeartRate)
                                heartRateMeasured = Date()
                                measured = true
                                
                                if (workoutStartTime.timeIntervalSince1970 > Date().timeIntervalSince1970) {
                                    return;
                                }
                                
                                if (rangeEditVisible) {
                                    return
                                }
                                
                                if (heartRate > appModel.maxHeartRate) {
                                    WKInterfaceDevice.current().play(.directionDown)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        WKInterfaceDevice.current().play(.directionDown)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        WKInterfaceDevice.current().play(.directionDown)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        WKInterfaceDevice.current().play(.directionDown)
                                    }
                                } else if (heartRate < appModel.minHeartRate) {
                                    WKInterfaceDevice.current().play(.directionUp)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        WKInterfaceDevice.current().play(.directionUp)
                                    }
                                }
                                
                                if (!permission_was_sometime_granted) {
                                    permission_was_sometime_granted = true
                                }
                            }
                            
                        }
                        
                        query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                        
                        if (query != nil) {
                            query!.updateHandler = updateHandler
                            
                            healthStore.execute(query!)
                        }
                    }
                }
            }.onDisappear {
                if (session.state == .running) {
                    session.invalidate()
                }
                if (query != nil) {
                    healthStore.stop(query!)
                }
            }.onChange(of: scenePhase) { phase in
                if (phase == .inactive || phase == .background) {
                    rangeEditVisible = false
                }
            }
    }
    
    func getHeartRateColor() -> Color {
        if (!measured || heartRate == 0) {
            return Color.gray
        } else if (heartRate < appModel.minHeartRate) {
            return Color.blue
        } else if (heartRate <= appModel.maxHeartRate) {
            return Color.green
        } else {
            return Color.red
        }
    }
}

struct WorkoutScreenView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutScreenView()
    }
}
