//
//  ContentView.swift
//  vorobei-sui-4
//
//  Created by Alexey Voronov on 10.10.2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var animation: CGFloat = 0.0
    let animationDuration: Double = 0.5
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.9))
                .frame(width: 80, height: 80)
                .opacity(viewModel.throttledValue ? 1.0 : 0.0)
            
            Button(action: {}, label: {
                ArrowIndicator(animation: animation)
                    .onTapGesture(perform: performAnimation)
            })
            .buttonStyle(SimpleButtonStyle())
            .offset(CGSize(width: -10.0, height: 0))
            .allowsHitTesting(animation == 0.0)
            .scaleEffect(CGSize(width: viewModel.throttledValue ? 0.86 : 1.0,
                                height: viewModel.throttledValue ? 0.86 : 1.0))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        self.viewModel.value = true
                    })
                    .onEnded({ _ in
                        self.viewModel.value = false
                    })
            )
        }
    }
    
    private func performAnimation() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            animation = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            animation = 0.0
        }
    }
}

struct ArrowIndicator: View {
    var animation: CGFloat
    
    var body: some View {
        HStack {
            Image(systemName: "arrowtriangle.right.fill")
                .padding(-8)
                .scaleEffect(animation)
                .offset(CGSize(width: 18.0 * animation + 9, height: 0))
                .opacity(animation)

            Image(systemName: "arrowtriangle.right.fill")
                .padding(-8)
                .offset(CGSize(width: 27.0 * animation, height: 0))
            Image(systemName: "arrowtriangle.right.fill")
                .padding(-8)
                .scaleEffect(1.0 - animation)
                .offset(CGSize(width: 18.0 * animation, height: 0))
                .opacity(1.0 - animation)
        }
        .font(.largeTitle)
        .foregroundColor(.blue)
        // Gestures or other modifiers can be added here
    }
}

struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

class ViewModel: ObservableObject {
    @Published var value: Bool = false
    @Published var throttledValue: Bool = false
    
    private var throttleCancellable: AnyCancellable? = nil
    
    init() {
        throttleCancellable = $value
            .throttle(for: .seconds(0.22), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] val in
                withAnimation(.easeIn(duration: 0.22)) {
                    self?.throttledValue = val
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
