//
//  ContentView.swift
//  ReduxSwiftUIDemo
//
//  Main list view with navigation
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        // Version-adaptive navigation / 版本适配的导航
        if #available(iOS 16.0, *) {
            // iOS 16+ uses NavigationStackStore / iOS 16+ 使用 NavigationStackStore
            NavigationStackStore(self.store.scope(state: \.path, action: \.path)) {
                DemoListView(store: store)
            } destination: { store in
                destinationView(for: store)
            }
        } else {
            // iOS 15 uses NavigationView with NavigationLink / iOS 15 使用 NavigationView 配合 NavigationLink
            NavigationView {
                DemoListViewIOS15(store: store)
            }
        }
    }
    
    // Extract destination view logic for reuse / 提取目标视图逻辑以便重用
    @ViewBuilder
    private func destinationView(for store: Store<AppFeature.Path.State, AppFeature.Path.Action>) -> some View {
        switch store.state {
        case .counter:
            if let store = store.scope(state: \.counter, action: \.counter) {
                CounterView(store: store)
            }
        case .networkRequest:
            if let store = store.scope(state: \.networkRequest, action: \.networkRequest) {
                ReduxPageStateBeRequestView(store: store)
            }
        case .refreshableList:
            if let store = store.scope(state: \.refreshableList, action: \.refreshableList) {
                RefreshableListView(store: store)
            }
        }
    }
}

// MARK: - Demo List View
struct DemoListView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List(viewStore.demoItems) { item in
                DemoItemRow(item: item) {
                    viewStore.send(.demoItemTapped(item))
                }
            }
            .navigationTitle("TCA Demos")
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(PlainListStyle())
            #endif
        }
    }
}

// MARK: - Demo Item Row
struct DemoItemRow: View {
    let item: DemoItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var rowContent: some View {
        HStack {
            itemIcon
            itemText
            Spacer()
            chevronIcon
        }
        .padding(.vertical, 8)
    }
    
    private var itemIcon: some View {
        Image(systemName: item.systemImage)
            .font(.title2)
            .foregroundColor(.blue)
            .frame(width: 40)
    }
    
    private var itemText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(item.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// MARK: - iOS 15 Navigation Support / iOS 15 导航支持
struct DemoListViewIOS15: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List(viewStore.demoItems) { item in
                NavigationLink(
                    destination: iOS15DestinationView(item: item, parentStore: store)
                ) {
                    DemoItemRowContent(item: item)
                }
            }
            .navigationTitle("TCA Demos")
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(PlainListStyle())
            #endif
        }
    }
}

// MARK: - iOS 15 Destination View Wrapper
// iOS 15 目标视图包装器 / iOS 15 Destination View Wrapper
struct iOS15DestinationView: View {
    let item: DemoItem
    let parentStore: StoreOf<AppFeature>
    
    // 每次视图出现时创建新的 Store / Create new Store each time view appears
    @State private var childStore: AnyView?
    
    var body: some View {
        Group {
            if let childStore = childStore {
                childStore
            } else {
                ProgressView()
                    .onAppear {
                        createFreshStore()
                    }
            }
        }
        .onAppear {
            // 每次进入页面时创建新的 Store / Create new Store each time entering the page
            createFreshStore()
        }
    }
    
    private func createFreshStore() {
        // 创建全新的 Store，确保状态被重置 / Create fresh Store to ensure state is reset
        switch item.id {
        case "counter":
            childStore = AnyView(
                CounterView(
                    store: Store(initialState: CounterFeature.State()) {
                        CounterFeature()
                    }
                )
            )
        case "network":
            childStore = AnyView(
                ReduxPageStateBeRequestView(
                    store: Store(initialState: ReduxPageStateBeRequestFeature.State()) {
                        ReduxPageStateBeRequestFeature()
                    }
                )
            )
        case "refreshableList":
            // 确保每次都是全新的状态，toggles 都是 false / Ensure fresh state with toggles set to false
            childStore = AnyView(
                RefreshableListView(
                    store: Store(
                        initialState: RefreshableListFeature.State(
                            pageState: .idle,
                            simulateError: false,  // 重置为 false / Reset to false
                            simulateEmpty: false,  // 重置为 false / Reset to false
                            refreshErrorInfo: nil
                        )
                    ) {
                        RefreshableListFeature()
                    }
                )
            )
        default:
            childStore = AnyView(Text("Unknown Demo"))
        }
    }
}

// MARK: - Demo Item Row Content / 演示项行内容
struct DemoItemRowContent: View {
    let item: DemoItem
    
    var body: some View {
        HStack {
            Image(systemName: item.systemImage)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}