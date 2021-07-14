//
//  ActivityIndicator.swift
//  HeartRateDisplay WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/3/21.
//

import SwiftUI

struct ActivityIndicator: View {
    private let animation = Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
    @State private var opacity = 0.0
    
    var body: some View {
        HStack {
            Image(systemName: "waveform.path.ecg")
                .font(.largeTitle)
                .opacity(opacity)
                .onAppear {
                    withAnimation(self.animation, {
                        self.opacity = self.opacity == 1 ? 0 : 1
                    })
                }
        }
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
