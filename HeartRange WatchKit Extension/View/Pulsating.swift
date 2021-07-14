//
//  Pulsating.swift
//  HeartRateDisplay WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/3/21.
//

import SwiftUI

fileprivate struct PulsationModifier: AnimatableModifier {
    @State var size: CGFloat = 1
    
    var active = true
    var speed = 69.0
    
    let nanosecondsInSecond: UInt64 = 1000 * 1000 * 1000
    
    func body(content: Content) -> some View {
        let delay = 60.0 / speed / 2
        
        if (!active) {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 2.0, dampingFraction: 0.5, blendDuration: 1)) {
                    size = 1
                }
            }
        } else if size == 0.8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                    size = 1.2
                }
            }
        } else if (size == 1.2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                    size = 0.8
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                    size = 0.8
                }
            }
        }
        
        return content
            .scaleEffect(x: size, y: size)
    }
}

extension View {
    func pulsating(active: Bool, speed: Double) -> some View {
        self.modifier(PulsationModifier(active: active, speed: speed))
    }
}

fileprivate struct PulsatingHeart: View {
    @State var active = true
    @State var speed: Double = 69
    
    var body: some View {
        VStack {
            Image(systemName: "heart.circle")
                .imageScale(.large)
                .foregroundColor(.red)
                .pulsating(active: active, speed: speed)
            Text("\(speed)")
            HStack {
                Button(action: {
                    speed += 1;
                }) {
                    Text("+")
                }
                Button(action: {
                    speed -= 1;
                }) {
                    Text("-")
                }
            }
            
            Button(action: {
                active.toggle()
            }) {
                Text("Toggle active")
            }
            
        }
    }
    
}

struct PulsatingHeart_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingHeart()
    }
}
