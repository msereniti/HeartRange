//
//  HomeScreenView.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/14/21.
//

import SwiftUI
import SwiftUIRouter

struct SetupScreenView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject private var navigator: Navigator
    
    
    var body: some View {
        VStack {
            HStack {
                Text("heartRange")
                    .font(.footnote)
                Spacer()
                Text(.init(systemName: "questionmark.circle"))
                    .font(.title3)
            }.onTapGesture(perform: {
                navigator.navigate("/recommendation")
            })
            Spacer()
            RangePickerView()
            Spacer()
            HStack {
                ZStack {
                    Button(action: {}) {
                        Group {
                            if (appModel.startDelay == 0) {
                                Text("startWorkout.now")
                            } else if (appModel.startDelay == 60) {
                                Text("startWorkout.1min")
                            } else if (appModel.startDelay == 60 * 5) {
                                Text("startWorkout.5min")
                            } else if (appModel.startDelay == 60 * 15) {
                                Text("startWorkout.15min")
                            } else {
                                Text("startWorkout.unknown \(appModel.startDelay)")
                            }
                        }
                            .padding(.leading, 2)
                        Spacer()
                        Text(.init(systemName: "ellipsis.circle"))
                            .font(.title3)
                            .padding(.trailing, 2)
                    }
                    HStack {
                        VStack{
                            Text("")
                                .frame(maxWidth: .infinity, minHeight: 50)
                        }
                            .background(Color.black)
                            .opacity(0.01)
                            .onTapGesture {
                                navigator.navigate("/workout")
                            }
                        VStack {
                            Text("")
                                .frame(width: 40, height: 50)
                        }
                            .background(Color.black)
                            .opacity(0.01)
                            .onTapGesture {
                                navigator.navigate("/delay")
                            }
                    }
                }
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.green)
                    .offset(y: 10)
            }.frame(height: 30)
        }
    }
}

struct SetupScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Router {
            SetupScreenView()
                .environmentObject(AppModel())
        }
    }
}
