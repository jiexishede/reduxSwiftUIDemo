//
//  ReduxPageStateBeRequestFeature.swift
//  ReduxSwiftUIDemo
//
//  Feature demonstrating network request states
//

import ComposableArchitecture
import Foundation

@Reducer
struct ReduxPageStateBeRequestFeature {
    @ObservableState
    struct State: Equatable {
        var pageState: SimplePageState = .normal
        var items: [String] = []
        var selectedRequestType: RequestType = .success
        
        enum RequestType: String, CaseIterable {
            case success = "Success"
            case failure = "Failure"
            case empty = "Empty"
        }
    }
    
    enum SimplePageState: Equatable {
        case normal
        case loading
        case success
        case failure(String)
        case empty
        
        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
    }
    
    enum Action {
        case fetchDataButtonTapped
        case dataResponse(Result<[String], Error>)
        case requestTypeChanged(State.RequestType)
        case resetButtonTapped
    }
    
    // 移除 @Dependency 以支持 iOS 15 / Remove @Dependency for iOS 15 support
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchDataButtonTapped:
                state.pageState = .loading
                state.items = []
                
                return .run { [requestType = state.selectedRequestType] send in
                    // 使用 Task.sleep 替代 clock.sleep 以支持 iOS 15 / Use Task.sleep instead of clock.sleep for iOS 15 support
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    
                    switch requestType {
                    case .success:
                        let mockData = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
                        await send(.dataResponse(.success(mockData)))
                    case .failure:
                        struct NetworkError: Error {}
                        await send(.dataResponse(.failure(NetworkError())))
                    case .empty:
                        await send(.dataResponse(.success([])))
                    }
                }
                
            case let .dataResponse(result):
                switch result {
                case let .success(items):
                    if items.isEmpty {
                        state.pageState = .empty
                        state.items = []
                    } else {
                        state.pageState = .success
                        state.items = items
                    }
                case .failure:
                    state.pageState = .failure("Network request failed. Please try again.")
                    state.items = []
                }
                return .none
                
            case let .requestTypeChanged(type):
                state.selectedRequestType = type
                state.pageState = .normal
                state.items = []
                return .none
                
            case .resetButtonTapped:
                state.pageState = .normal
                state.items = []
                return .none
            }
        }
    }
}