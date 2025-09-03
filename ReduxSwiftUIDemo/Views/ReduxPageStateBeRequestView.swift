//
//  ReduxPageStateBeRequestView.swift
//  ReduxSwiftUIDemo
//
//  View demonstrating network request states
//

import SwiftUI
import ComposableArchitecture

struct ReduxPageStateBeRequestView: View {
    let store: StoreOf<ReduxPageStateBeRequestFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                RequestTypeSelector(viewStore: viewStore)
                StateContentView(viewStore: viewStore)
                ActionButtonsView(viewStore: viewStore)
            }
            .navigationTitle("Network Request Demo")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

// MARK: - Request Type Selector
struct RequestTypeSelector: View {
    let viewStore: ViewStore<ReduxPageStateBeRequestFeature.State, ReduxPageStateBeRequestFeature.Action>
    
    var body: some View {
        Picker("Request Type", selection: viewStore.binding(
            get: \.selectedRequestType,
            send: ReduxPageStateBeRequestFeature.Action.requestTypeChanged
        )) {
            ForEach(ReduxPageStateBeRequestFeature.State.RequestType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

// MARK: - State Content View
struct StateContentView: View {
    let viewStore: ViewStore<ReduxPageStateBeRequestFeature.State, ReduxPageStateBeRequestFeature.Action>
    
    var body: some View {
        Group {
            switch viewStore.pageState {
            case .normal:
                SimpleNormalStateView()
            case .loading:
                SimpleLoadingStateView()
            case .success:
                SimpleSuccessStateView(items: viewStore.items)
            case .failure(let message):
                SimpleFailureStateView(message: message)
            case .empty:
                SimpleEmptyStateView()
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Action Buttons View
struct ActionButtonsView: View {
    let viewStore: ViewStore<ReduxPageStateBeRequestFeature.State, ReduxPageStateBeRequestFeature.Action>
    
    var body: some View {
        VStack(spacing: 12) {
            fetchDataButton
            resetButton
        }
        .padding(.horizontal)
    }
    
    private var fetchDataButton: some View {
        Button(action: { viewStore.send(.fetchDataButtonTapped) }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Fetch Data")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(viewStore.pageState.isLoading)
    }
    
    private var resetButton: some View {
        Group {
            if viewStore.pageState != .normal {
                Button(action: { viewStore.send(.resetButtonTapped) }) {
                    Text("Reset")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - State Views
struct SimpleNormalStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            stateIcon
            stateText
        }
    }
    
    private var stateIcon: some View {
        Image(systemName: "network")
            .font(.system(size: 60))
            .foregroundColor(.gray)
    }
    
    private var stateText: some View {
        VStack(spacing: 8) {
            Text("Ready to fetch data")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Select a request type and tap 'Fetch Data'")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SimpleLoadingStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

struct SimpleSuccessStateView: View {
    let items: [String]
    
    var body: some View {
        VStack {
            successHeader
            itemsList
        }
    }
    
    private var successHeader: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Success!")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding(.bottom)
    }
    
    private var itemsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    SimpleItemRow(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SimpleItemRow: View {
    let item: String
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(item)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SimpleFailureStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            errorIcon
            errorText
        }
    }
    
    private var errorIcon: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.red)
    }
    
    private var errorText: some View {
        VStack(spacing: 8) {
            Text("Request Failed")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct SimpleEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            emptyIcon
            emptyText
        }
    }
    
    private var emptyIcon: some View {
        Image(systemName: "tray")
            .font(.system(size: 60))
            .foregroundColor(.gray)
    }
    
    private var emptyText: some View {
        VStack(spacing: 8) {
            Text("No Data")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("The request succeeded but returned no items")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}