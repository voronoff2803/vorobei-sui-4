//
//  ContentView.swift
//  vorobei-sui-4
//
//  Created by Alexey Voronov on 10.10.2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var animation: Double = 0.0
    let animationDuration: Double = 0.5
    
    var body: some View {
        ZStack {
            Button(action: { self.performTapAnimation() }, label: {
                ArrowIndicator(animation: animation)
            })
            .buttonStyle(SimpleButtonStyle())
        }
    }
    
    func performTapAnimation() {
        guard animation == 0.0 else { return }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            self.animation = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.animation = 0.0
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
    @ObservedObject var viewModel = ViewModel()
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.9))
                .frame(width: 80, height: 80)
                .opacity(viewModel.throttledValue ? 1.0 : 0.0)
            
            
            
            configuration.label
                .offset(CGSize(width: -10.0, height: 0))
                .scaleEffect(CGSize(width: viewModel.throttledValue ? 0.86 : 1.0,
                                    height: viewModel.throttledValue ? 0.86 : 1.0))
        }
        .onChange(of: configuration.isPressed) { _, newValue in
            self.viewModel.value = newValue
        }
    }
}

class ViewModel: ObservableObject {
    @Published var value: Bool = false
    @Published var throttledValue: Bool = false
    @Published var animation: CGFloat = 0.0
    
    private var throttleCancellable: AnyCancellable? = nil
    
    init() {
        throttleCancellable = $value
            .removeDuplicates()
            .throttle(for: .seconds(0.22), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] val in
                print(Unmanaged.passUnretained(self!).toOpaque(), "throttle", val)
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
