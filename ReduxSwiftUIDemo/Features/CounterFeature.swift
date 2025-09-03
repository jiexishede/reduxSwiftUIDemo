//
//  CounterFeature.swift
//  ReduxSwiftUIDemo
//
//  Counter Feature demonstrating TCA with Side Effects
//

import ComposableArchitecture
import Foundation

@Reducer
struct CounterFeature {
    @ObservableState
    struct State: Equatable {
        var count = 0
        var isTimerActive = false
        var randomFactAlert: String?
    }
    
    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
        case resetButtonTapped
        case toggleTimerButtonTapped
        case timerTick
        case getRandomFactButtonTapped
        case randomFactResponse(String)
        case dismissRandomFactAlert
    }
    
    private enum CancelID { 
        case timer 
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .resetButtonTapped:
                state.count = 0
                state.isTimerActive = false
                return .cancel(id: CancelID.timer)
                
            case .toggleTimerButtonTapped:
                state.isTimerActive.toggle()
                if state.isTimerActive {
                    return .run { send in
                        // 使用 Task.sleep 替代 clock.timer 以支持 iOS 15 / Use Task.sleep instead of clock.timer for iOS 15 support
                        while true {
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
                
            case .timerTick:
                state.count += 1
                return .none
                
            case .getRandomFactButtonTapped:
                return .run { [count = state.count] send in
                    let fact = await getNumberFact(for: count)
                    await send(.randomFactResponse(fact))
                }
                
            case let .randomFactResponse(fact):
                state.randomFactAlert = fact
                return .none
                
            case .dismissRandomFactAlert:
                state.randomFactAlert = nil
                return .none
            }
        }
    }
    
    private func getNumberFact(for number: Int) async -> String {
        do {
            let url = URL(string: "http://numbersapi.com/\(number)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8) ?? "Could not load fact"
        } catch {
            return "Could not load fact: \(error.localizedDescription)"
        }
    }
}