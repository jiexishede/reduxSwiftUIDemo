//
//  CounterView.swift
//  ReduxSwiftUIDemo
//
//  Counter feature view
//

import SwiftUI
import ComposableArchitecture

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                Text("Count: \(viewStore.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    Button(action: { viewStore.send(.decrementButtonTapped) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    
                    Button(action: { viewStore.send(.incrementButtonTapped) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: { viewStore.send(.resetButtonTapped) }) {
                        Text("Reset")
                            .padding(.horizontal)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { viewStore.send(.toggleTimerButtonTapped) }) {
                        Text(viewStore.isTimerActive ? "Stop Timer" : "Start Timer")
                            .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button(action: { viewStore.send(.getRandomFactButtonTapped) }) {
                    Text("Get Random Fact")
                        .padding(.horizontal)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Counter Demo")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Number Fact",
                isPresented: .constant(viewStore.randomFactAlert != nil),
                presenting: viewStore.randomFactAlert
            ) { _ in
                Button("OK") {
                    viewStore.send(.dismissRandomFactAlert)
                }
            } message: { fact in
                Text(fact)
            }
        }
    }
}