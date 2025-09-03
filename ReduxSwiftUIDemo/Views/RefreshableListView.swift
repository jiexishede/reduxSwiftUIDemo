//
//  RefreshableListView.swift
//  ReduxSwiftUIDemo
//
//  List view with pull-to-refresh and load-more capabilities
//  支持下拉刷新和加载更多功能的列表视图
//

import SwiftUI
import ComposableArchitecture

// MARK: - Loading Overlay
// 加载遮罩层 / Loading Overlay
struct LoadingOverlay: View {
    let isLoading: Bool
    let message: String
    
    init(isLoading: Bool, message: String = "加载中... / Loading...") {
        self.isLoading = isLoading
        self.message = message
    }
    
    var body: some View {
        if isLoading {
            ZStack {
                // 背景遮罩 - 使用半透明黑色，可以拦截交互 / Background overlay - semi-transparent black to intercept interactions
                Color.black
                    .opacity(0.4) // 稍微提高透明度，让遮罩效果更明显 / Slightly higher opacity for better masking effect
                    .ignoresSafeArea() // 覆盖整个屏幕包括安全区域 / Cover entire screen including safe areas
                    .onTapGesture {
                        // 空实现，仅用于拦截点击 / Empty implementation, just to intercept taps
                    }
                    .allowsHitTesting(true) // 确保拦截所有触摸事件 / Ensure all touch events are intercepted
                
                // 中央加载指示器卡片 / Central loading indicator card
                VStack(spacing: 20) {
                    // 加载动画 / Loading animation
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                    
                    // 加载文字 / Loading text
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
            .zIndex(999) // 确保在最顶层 / Ensure it's on top
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
    }
}

// MARK: - Filter Loading Overlay
// 筛选加载遮罩 / Filter Loading Overlay
struct FilterLoadingOverlay: View {
    let isChangingFilter: Bool
    
    var body: some View {
        if isChangingFilter {
            ZStack {
                // 全屏半透明遮罩 / Full screen semi-transparent overlay
                Color.black
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(true) // 确保可以拦截交互 / Ensure it intercepts interactions
                
                // 简洁的加载指示器 / Simple loading indicator
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                    
                    Text("切换筛选中... / Switching filter...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(24)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.15), value: isChangingFilter)
        }
    }
}

struct RefreshableListView: View {
    let store: StoreOf<RefreshableListFeature>
    
    // 根据状态获取加载消息 / Get loading message based on state
    private func getLoadingMessage(viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>) -> String {
        // 检查是否在切换筛选 / Check if changing filter
        if viewStore.isChangingFilter {
            return "切换筛选中... / Switching filter..."
        }
        
        // 检查页面状态类型 / Check page state type
        switch viewStore.pageState {
        case .loading(.initial):
            return "加载数据中... / Loading data..."
        case .loading(.refresh):
            return "刷新数据中... / Refreshing data..."
        case .loaded(_, .loading):
            return "加载更多... / Loading more..."
        default:
            return "处理中... / Processing..."
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                // 主内容 / Main content
                VStack(spacing: 0) {
                    // 筛选下拉菜单 / Filter Dropdown
                    OrderFilterDropdown(viewStore: viewStore)
                    // 控制面板 / Control Panel
                    ControlPanel(viewStore: viewStore)
                    // 列表内容 / List Content
                    ListContent(viewStore: viewStore)
                }
                
                // 加载遮罩层 - 覆盖在所有内容之上 / Loading overlay - covers all content
                LoadingOverlay(
                    isLoading: viewStore.showLoadingOverlay,
                    message: getLoadingMessage(viewStore: viewStore)
                )
            }
            .navigationTitle("订单列表 / Order List")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// MARK: - Order Filter Dropdown
// 订单筛选下拉菜单 / Order Filter Dropdown
struct OrderFilterDropdown: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        VStack(spacing: 0) {
            // 筛选按钮 / Filter button
            Button(action: { viewStore.send(.toggleFilterDropdown) }) {
                HStack {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.title3)
                    
                    Text(viewStore.selectedFilter.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: viewStore.showFilterDropdown ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
            }
            .foregroundColor(.primary)
            
            // 下拉选项列表 / Dropdown options list
            if viewStore.showFilterDropdown {
                VStack(spacing: 0) {
                    // 全部订单 / All orders
                    FilterOption(
                        title: OrderFilterOption.all.displayName,
                        isSelected: viewStore.selectedFilter == .all,
                        action: { viewStore.send(.selectFilter(.all)) }
                    )
                    
                    Divider()
                    
                    // 各个订单状态 / Each order status
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        FilterOption(
                            title: OrderFilterOption.status(status).displayName,
                            systemImage: status.systemImage,
                            color: colorFromString(status.color),
                            isSelected: viewStore.selectedFilter == .status(status),
                            action: { viewStore.send(.selectFilter(.status(status))) }
                        )
                        
                        if status != OrderStatus.allCases.last {
                            Divider()
                        }
                    }
                    
                    Divider()
                    
                    // 无订单（特殊筛选）/ No orders (special filter)
                    FilterOption(
                        title: OrderFilterOption.noOrders.displayName,
                        systemImage: "tray",
                        color: .gray,
                        isSelected: viewStore.selectedFilter == .noOrders,
                        action: { viewStore.send(.selectFilter(.noOrders)) }
                    )
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 5)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: viewStore.showFilterDropdown)
            }
        }
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        case "gray": return .gray
        default: return .gray
        }
    }
}

// MARK: - Filter Option Row
// 筛选选项行 / Filter Option Row
struct FilterOption: View {
    let title: String
    var systemImage: String? = nil
    var color: Color = .primary
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.body)
                        .foregroundColor(color)
                        .frame(width: 24)
                }
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
        }
    }
}

// MARK: - Order Status Badge
// 订单状态标签 / Order Status Badge
struct OrderStatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemImage)
                .font(.caption2)
            
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorFromString(status.color).opacity(0.15))
        .foregroundColor(colorFromString(status.color))
        .cornerRadius(6)
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        case "gray": return .gray
        default: return .gray
        }
    }
}

// MARK: - Control Panel
// 控制面板 / Control Panel
struct ControlPanel: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        VStack(spacing: 12) {
            toggleButtons
            statusText
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private var toggleButtons: some View {
        HStack(spacing: 16) {
            Toggle("模拟错误 / Simulate Error", isOn: viewStore.binding(
                get: \.simulateError,
                send: { _ in .toggleErrorSimulation }
            ))
            .toggleStyle(SwitchToggleStyle())
            
            Toggle("模拟空数据 / Simulate Empty", isOn: viewStore.binding(
                get: \.simulateEmpty,
                send: { _ in .toggleEmptySimulation }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .font(.caption)
    }
    
    private var statusText: some View {
        Group {
            if viewStore.simulateError {
                Label("错误模式：请求将失败 / Error mode: Requests will fail", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.caption)
            } else if viewStore.simulateEmpty {
                Label("空数据模式：不返回数据 / Empty mode: No data will be returned", systemImage: "tray")
                    .foregroundColor(.blue)
                    .font(.caption)
            } else {
                Label("正常模式：数据正常加载 / Normal mode: Data will load successfully", systemImage: "checkmark.circle")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
    }
}

// MARK: - List Content
// 列表内容 / List Content
struct ListContent: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        Group {
            if viewStore.showInitialLoading {
                InitialLoadingView()
            } else if viewStore.showInitialError {
                InitialErrorView(viewStore: viewStore)
            } else if viewStore.showEmptyView {
                EmptyListView()
            } else {
                // 根据iOS版本选择不同的实现 / Choose implementation based on iOS version
                if #available(iOS 16.0, *) {
                    ModernRefreshableScrollView(viewStore: viewStore)
                } else {
                    // iOS 15.0 版本 / iOS 15.0 version
                    LegacyRefreshableScrollView(viewStore: viewStore)
                }
            }
        }
    }
}

// MARK: - iOS 16+ Refreshable ScrollView
// iOS 16+ 可刷新滚动视图 / iOS 16+ Refreshable ScrollView
@available(iOS 16.0, *)
struct ModernRefreshableScrollView: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 刷新错误视图 / Refresh error view
                RefreshErrorView(viewStore: viewStore)
                
                LazyVStack(spacing: 0) {
                    itemsList
                    loadMoreSection
                }
            }
        }
        .refreshable {
            // 使用async/await处理刷新 / Handle refresh with async/await
            await withCheckedContinuation { continuation in
                viewStore.send(.pullToRefresh)
                
                // 监听状态变化来结束刷新 / Monitor state change to end refresh
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    continuation.resume()
                }
            }
        }
        .onAppear {
            // 确保刷新状态正确 / Ensure refresh state is correct
            isRefreshing = viewStore.pageState.isRefreshing
        }
    }
    
    private var itemsList: some View {
        ForEach(viewStore.items) { item in
            ListItemView(item: item)
        }
    }
    
    private var loadMoreSection: some View {
        Group {
            if case let .loaded(data, loadMoreState) = viewStore.pageState {
                LoadMoreView(
                    loadMoreState: loadMoreState,
                    hasMore: data.hasMorePages
                ) {
                    viewStore.send(.loadMore)
                }
            }
        }
    }
}

// MARK: - iOS 15 Refreshable ScrollView
// iOS 15 可刷新滚动视图 / iOS 15 Refreshable ScrollView
struct LegacyRefreshableScrollView: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        // iOS 15 使用 List 以支持 refreshable / Use List for iOS 15 to support refreshable
        List {
            // 刷新错误横幅（与 iOS 16 相同的样式）/ Refresh error banner (same style as iOS 16)
            if case let .failed(.refresh, errorInfo) = viewStore.pageState {
                RefreshErrorBanner(errorInfo: errorInfo, viewStore: viewStore)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else if let errorInfo = viewStore.refreshErrorInfo {
                // 显示刷新错误信息 / Show refresh error info
                RefreshErrorBanner(errorInfo: errorInfo, viewStore: viewStore)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            
            // 列表项 / List items
            ForEach(viewStore.items) { item in
                ListItemView(item: item)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            
            // 加载更多部分 / Load more section
            if case let .loaded(data, loadMoreState) = viewStore.pageState {
                LoadMoreView(
                    loadMoreState: loadMoreState,
                    hasMore: data.hasMorePages
                ) {
                    viewStore.send(.loadMore)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            // 异步刷新处理 / Async refresh handling
            await performRefresh()
        }
    }
    
    // 执行刷新的异步函数 / Async function to perform refresh
    private func performRefresh() async {
        // 发送刷新动作 / Send refresh action
        viewStore.send(.pullToRefresh)
        
        // 等待一小段时间确保动作被处理 / Wait a moment to ensure action is processed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒 / 0.1 second
        
        // 等待刷新完成（最多5秒）/ Wait for refresh to complete (max 5 seconds)
        var attempts = 0
        let maxAttempts = 50
        
        // 等待刷新开始 / Wait for refresh to start
        while !viewStore.pageState.isRefreshing && attempts < 5 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }
        
        // 等待刷新完成 / Wait for refresh to complete
        attempts = 0
        while viewStore.pageState.isRefreshing && attempts < maxAttempts {
            try? await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }
    }
}

// MARK: - Refresh Error Banner for List
// 列表刷新错误横幅 / Refresh Error Banner for List
struct RefreshErrorBanner: View {
    let errorInfo: ReduxPageState<ListData<MockItem>>.ErrorInfo
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("刷新失败 / Refresh Failed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(errorInfo.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: { viewStore.send(.pullToRefresh) }) {
                    Text("重试 / Retry")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                }
            }
            .padding()
            
            Divider()
        }
        .background(Color.yellow.opacity(0.1))
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: errorInfo)
    }
}

// MARK: - Refresh Error View
// 刷新错误视图 / Refresh Error View
struct RefreshErrorView: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        // 只在刷新失败且有数据时显示 / Only show when refresh failed and has data
        if case let .failed(.refresh, errorInfo) = viewStore.pageState {
            errorBanner(errorInfo: errorInfo)
        } else if case let .loaded(data, _) = viewStore.pageState,
                  !data.items.isEmpty,
                  viewStore.refreshErrorInfo != nil {
            if let errorInfo = viewStore.refreshErrorInfo {
                errorBanner(errorInfo: errorInfo)
            }
        }
    }
    
    private func errorBanner(errorInfo: ReduxPageState<ListData<MockItem>>.ErrorInfo) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("刷新失败 / Refresh Failed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(errorInfo.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: { viewStore.send(.pullToRefresh) }) {
                    Text("重试 / Retry")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                }
            }
            .padding()
            
            Divider()
        }
        .background(Color.yellow.opacity(0.1))
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: viewStore.refreshErrorInfo)
    }
}

// MARK: - Scroll Offset Preference Key
// 滚动偏移偏好键 / Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Initial Loading View
// 初始加载视图 / Initial Loading View
struct InitialLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("加载中... / Loading data...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Initial Error View
// 初始错误视图 / Initial Error View
struct InitialErrorView: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    
    var body: some View {
        VStack(spacing: 20) {
            errorIcon
            errorMessage
            retryButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var errorIcon: some View {
        Image(systemName: "wifi.exclamationmark")
            .font(.system(size: 60))
            .foregroundColor(.red)
    }
    
    private var errorMessage: some View {
        VStack(spacing: 8) {
            Text("加载失败 / Failed to Load")
                .font(.title3)
                .fontWeight(.semibold)
            
            if let error = viewStore.pageState.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var retryButton: some View {
        Button(action: { viewStore.send(.retry) }) {
            Label("重试 / Retry", systemImage: "arrow.clockwise")
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// MARK: - Empty List View
// 空列表视图 / Empty List View
struct EmptyListView: View {
    var body: some View {
        VStack(spacing: 20) {
            emptyIcon
            emptyText
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyIcon: some View {
        Image(systemName: "tray")
            .font(.system(size: 60))
            .foregroundColor(.gray)
    }
    
    private var emptyText: some View {
        VStack(spacing: 8) {
            Text("没有数据 / No Items")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("暂无可显示的数据 / There are no items to display")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - List Item View
// 列表项视图 / List Item View
struct ListItemView: View {
    let item: MockItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            itemHeader
            itemContent
            itemFooter
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .overlay(divider, alignment: .bottom)
    }
    
    private var itemHeader: some View {
        HStack {
            // 订单号 / Order number
            Text(item.orderNumber)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // 订单状态标签 / Order status badge
            OrderStatusBadge(status: item.orderStatus)
        }
    }
    
    private var itemContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text(item.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
    
    private var itemFooter: some View {
        HStack {
            // 金额 / Amount
            Text("¥\(String(format: "%.2f", item.amount))")
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()
            
            // 时间 / Time
            Text(timeString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 0.5)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: item.timestamp)
    }
}

// MARK: - Load More View
// 加载更多视图 / Load More View
struct LoadMoreView: View {
    let loadMoreState: ReduxPageState<ListData<MockItem>>.LoadMoreState
    let hasMore: Bool
    let onLoadMore: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            content
        }
        .frame(minHeight: 80)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var content: some View {
        switch loadMoreState {
        case .idle:
            if hasMore {
                loadMoreButton
            }
            
        case .loading:
            loadingIndicator
            
        case .noMore:
            noMoreText
            
        case let .failed(errorInfo):
            failedView(errorInfo: errorInfo)
        }
    }
    
    private var loadMoreButton: some View {
        Button(action: onLoadMore) {
            Text("加载更多 / Load More")
                .foregroundColor(.blue)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
    }
    
    private var loadingIndicator: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("正在加载更多... / Loading more...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var noMoreText: some View {
        Text("没有更多数据 / No more items")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    // 加载更多失败视图 / Load more failed view
    private func failedView(errorInfo: ReduxPageState<ListData<MockItem>>.ErrorInfo) -> some View {
        VStack(spacing: 12) {
            // 错误图标和信息 / Error icon and info
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("加载更多失败 / Failed to load more")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    
                    Text(errorInfo.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // 重试按钮 / Retry button
            Button(action: onLoadMore) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                    Text("点击重试 / Tap to retry")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}