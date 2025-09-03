//
//  AppFeature.swift
//  ReduxSwiftUIDemo
//
//  Main App Feature with Navigation
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var demoItems: [DemoItem] = DemoItem.allItems
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case demoItemTapped(DemoItem)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .demoItemTapped(item):
                switch item.id {
                case "counter":
                    state.path.append(.counter(CounterFeature.State()))
                case "network":
                    state.path.append(.networkRequest(ReduxPageStateBeRequestFeature.State()))
                case "refreshableList":
                    state.path.append(.refreshableList(RefreshableListFeature.State()))
                default:
                    break
                }
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case counter(CounterFeature.State)
            case networkRequest(ReduxPageStateBeRequestFeature.State)
            case refreshableList(RefreshableListFeature.State)
        }
        
        enum Action {
            case counter(CounterFeature.Action)
            case networkRequest(ReduxPageStateBeRequestFeature.Action)
            case refreshableList(RefreshableListFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.counter, action: \.counter) {
                CounterFeature()
            }
            Scope(state: \.networkRequest, action: \.networkRequest) {
                ReduxPageStateBeRequestFeature()
            }
            Scope(state: \.refreshableList, action: \.refreshableList) {
                RefreshableListFeature()
            }
        }
    }
}

// MARK: - Demo Item Model
struct DemoItem: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    
    static let allItems = [
        DemoItem(
            id: "counter",
            title: "Counter Demo",
            subtitle: "Increment, decrement, timer, and random facts",
            systemImage: "number.circle"
        ),
        DemoItem(
            id: "network",
            title: "Network Request States",
            subtitle: "Loading, success, failure, and empty states",
            systemImage: "network"
        ),
        DemoItem(
            id: "refreshableList",
            title: "Refreshable List",
            subtitle: "Pull-to-refresh, load more, empty & error states",
            systemImage: "arrow.clockwise.square"
        )
    ]
}