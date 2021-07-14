//
//  RecommendationScreenView.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/15/21.
//

import SwiftUI
import SwiftUIRouter
import HealthKit
import AlertKit

struct RecommendationScreenView: View {
    private let healthStore = HKHealthStore()
    private let heartRateQuantity = HKUnit(from: "count/min")
    
    @SceneStorage("app.recommendationsScreen.age") private var age: Double = 25
    @SceneStorage("app.recommendationsScreen.restHeartRate") private var restHeartRate: Double = 70
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var navigator: Navigator
    
    @State var recomendedMinHeartRate: Int = 0
    @State var recomendedMaxHeartRate: Int = 0
    
    @State var heartRateMeasureInProgress = false
    @State var heartRateMeasureError = false
    
    @StateObject var alertManager = AlertManager()
    
    var body: some View {
        func formatAge(age: Double) -> String {
            if (age < 20) {
                return "<20"
            } else if (age > 55) {
                return ">60"
            } else {
                return "\(Int(age))-\(Int(age + 5))"
            }
        }
        
        func calc() {
            // https://ru.wikipedia.org/wiki/Метод_Карвонена
            // https://www.uclahealth.org/geriatrics/workfiles/fellowship/current-fellows/goals-and-objectives/wlareh/karvonen-formula.pdf
            let maxAllowed = 220 - age
            let minIntencity = 0.5
            let maxIntencity = 0.8
            
            recomendedMinHeartRate = Int((restHeartRate + (maxAllowed - restHeartRate) * minIntencity) / 5) * 5
            recomendedMaxHeartRate = Int((restHeartRate + (maxAllowed - restHeartRate) * maxIntencity) / 5) * 5
        }
        
        return ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .font(.title3)
                        .padding(.top, 6)
                        .padding(.bottom, 2)
                        .onTapGesture {
                            navigator.navigate("/setup")
                        }
                }
                VStack(alignment: .leading) {
                    Text("recommendations.title")
                        .font(.body)
                        .padding(.bottom, 12)
                    Text("recommendations.disclaimer")
                        .font(.footnote)
                        .padding(.bottom, 12)
                    Text("recommendations.age \(formatAge(age: age))")
                }
                Slider(value: $age, in: 15...60, step: 5)
                    .padding(.vertical, 10)
                    .accentColor(.green)
                    .onChange(of: age, perform: { _ in calc() })
                Text("recommendations.heartRate \(Int(restHeartRate))")
                Slider(value: $restHeartRate, in: 30...150, step: 10)
                    .padding(.vertical, 10)
                    .accentColor(.green)
                    .onChange(of: restHeartRate, perform: { _ in calc() })
                if (!heartRateMeasureError) {
                    Button(action: {
                        heartRateMeasureInProgress = true
                        
                        let healthKitType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!
                        let readPermissionTypes: Set = [healthKitType]
                        
                        healthStore.requestAuthorization(toShare: [], read: readPermissionTypes) { (success, error) in
                            if !success {
                                heartRateMeasureInProgress = false
                                heartRateMeasureError = true
                                alertManager.show(dismiss: .success(title: String.localizedString(for: "error"), message: error?.localizedDescription ?? String.localizedString(for: "unknownError")))
                            } else {
                                let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
                                
                                var query: HKAnchoredObjectQuery
                                
                                let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                                    query, samples, deletedObjects, queryAnchor, error in
                                    
                                    if (error != nil) {
                                        heartRateMeasureError = true
                                        alertManager.show(dismiss: .success(title: String.localizedString(for: "error"), message: error?.localizedDescription ?? String.localizedString(for: "unknownError")))
                                    }
                                    
                                    heartRateMeasureInProgress = false
                                    
                                    guard let samples = samples as? [HKQuantitySample] else {
                                        return
                                    }
                                    
                                    var lastHeartRate = 0.0
                                    
                                    for sample in samples {
                                        lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                                    }
                                    
                                    restHeartRate = lastHeartRate
                                    healthStore.stop(query)
                                    DispatchQueue.main.async {
                                        calc()
                                    }
                                }
                                
                                query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                                
                                query.updateHandler = updateHandler
                                
                                healthStore.execute(query)
                            }
                        }
                        
                    }) {
                        HStack {
                            if (heartRateMeasureInProgress) {
                                Image(systemName: "heart.circle")
                                    .imageScale(.large)
                                    .animation(.easeInOut(duration: 0.3))
                                    .pulsating(active: true, speed: 70.0)
                            } else {
                                Image(systemName: "heart.text.square")
                                    .imageScale(.large)
                            }
                            
                            Text("recommendations.measureHeartRate")
                                .font(.caption)
                        }
                    }
                    
                }
                
                Text("recommendations.result \(recomendedMinHeartRate) \(recomendedMaxHeartRate)")
                Button("recommendations.useResult \(recomendedMinHeartRate) \(recomendedMaxHeartRate)", action: {
                    appModel.minHeartRate = recomendedMinHeartRate
                    appModel.maxHeartRate = recomendedMaxHeartRate
                    navigator.navigate("/setup")
                })
                    .foregroundColor(.green)
                NavLink(to: "/setup") {
                    Text("recommendations.cancel")
                }
                Text("recommendations.description")
                    .font(.footnote)
                    .padding(.top, 30)
            }
                .uses(alertManager)
                .onAppear {
                    calc()
                }
        }
    }}

struct RecommendationScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Router {
            RecommendationScreenView()
                .environmentObject(AppModel())
        }
    }
}
