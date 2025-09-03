//
//  RefreshableListFeature.swift
//  ReduxSwiftUIDemo
//
//  Feature for list with pull-to-refresh and load-more
//  支持下拉刷新和加载更多的列表功能
//

import ComposableArchitecture
import Foundation

// MARK: - Order Filter Option
// 订单筛选选项 / Order Filter Option
enum OrderFilterOption: Equatable {
    case all                      // 全部 / All
    case status(OrderStatus)      // 特定状态 / Specific status
    case noOrders                 // 无订单（特殊状态）/ No orders (special state)
    
    var displayName: String {
        switch self {
        case .all:
            return "全部订单 / All Orders"
        case .status(let status):
            return "\(status.rawValue) / \(status.englishName)"
        case .noOrders:
            return "无订单 / No Orders"
        }
    }
}

@Reducer
struct RefreshableListFeature {
    @ObservableState
    struct State: Equatable {
        /// 页面状态 / Page state
        var pageState: ReduxPageState<ListData<MockItem>> = .idle
        /// 是否模拟错误 / Simulate error flag
        var simulateError: Bool = false
        /// 是否模拟空数据 / Simulate empty data flag
        var simulateEmpty: Bool = false
        /// 刷新错误信息（用于显示错误提示条）/ Refresh error info (for error banner)
        var refreshErrorInfo: ReduxPageState<ListData<MockItem>>.ErrorInfo?
        /// 当前选择的筛选选项 / Current selected filter option
        var selectedFilter: OrderFilterOption = .all
        /// 是否显示筛选下拉菜单 / Show filter dropdown
        var showFilterDropdown: Bool = false
        /// 是否正在切换筛选 / Is changing filter
        var isChangingFilter: Bool = false
        /// 是否显示全屏加载遮罩 / Show full screen loading overlay
        var showLoadingOverlay: Bool = false
        
        // MARK: - Computed Properties
        // 计算属性 / Computed Properties
        
        /// 获取列表项 / Get list items
        var items: [MockItem] {
            if case let .loaded(data, _) = pageState {
                return data.items
            }
            return []
        }
        
        /// 是否显示空视图 / Should show empty view
        var showEmptyView: Bool {
            if case let .loaded(data, _) = pageState {
                return data.isEmpty
            }
            return false
        }
        
        /// 是否显示初始加载 / Should show initial loading
        var showInitialLoading: Bool {
            if case .loading(.initial) = pageState {
                return true
            }
            return false
        }
        
        /// 是否显示初始错误 / Should show initial error
        var showInitialError: Bool {
            if case .failed(.initial, _) = pageState {
                return true
            }
            return false
        }
    }
    
    enum Action {
        /// 页面出现 / On appear
        case onAppear
        /// 下拉刷新 / Pull to refresh
        case pullToRefresh
        /// 加载更多 / Load more
        case loadMore
        /// 数据响应 / Data response
        case dataResponse(Result<ListData<MockItem>, Error>, isLoadMore: Bool, previousData: ListData<MockItem>?)
        /// 切换错误模拟 / Toggle error simulation
        case toggleErrorSimulation
        /// 切换空数据模拟 / Toggle empty simulation
        case toggleEmptySimulation
        /// 重试 / Retry
        case retry
        /// 切换筛选下拉菜单 / Toggle filter dropdown
        case toggleFilterDropdown
        /// 选择筛选选项 / Select filter option
        case selectFilter(OrderFilterOption)
    }
    
    // 移除 @Dependency 以支持 iOS 15 / Remove @Dependency for iOS 15 support
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 仅在空闲状态时加载 / Only load when idle
                guard case .idle = state.pageState else { return .none }
                state.pageState = .loading(.initial)
                // 初始加载时显示遮罩层 / Show overlay during initial load
                state.showLoadingOverlay = true
                
                return .run { [simulateEmpty = state.simulateEmpty, simulateError = state.simulateError, filter = state.selectedFilter] send in
                    let requestType: NetworkRequestManager.RequestResult = simulateError ? .failure : (simulateEmpty ? .successWithEmpty : .success)
                    
                    do {
                        let data = try await NetworkRequestManager.simulateListRequest(
                            page: 0,
                            requestType: requestType,
                            filterOption: filter
                        )
                        await send(.dataResponse(.success(data), isLoadMore: false, previousData: nil))
                    } catch {
                        await send(.dataResponse(.failure(error), isLoadMore: false, previousData: nil))
                    }
                }
                
            case .pullToRefresh:
                // 如果正在加载，不处理 / Don't handle if already loading
                guard !state.pageState.isLoading else { return .none }
                
                // 下拉刷新时显示遮罩层 / Show overlay during pull-to-refresh
                state.showLoadingOverlay = true
                
                // 清除之前的刷新错误信息 / Clear previous refresh error info
                state.refreshErrorInfo = nil
                
                // 保存当前数据（如果有）/ Save current data (if any)
                var previousData: ListData<MockItem>? = nil
                if case let .loaded(data, _) = state.pageState {
                    previousData = data
                }
                
                // 刷新时重置为loading状态，这样会从第一页开始 / Reset to loading state for refresh, starting from page 1
                // 如果之前有数据，设置为refresh类型 / If had data before, set as refresh type
                if previousData != nil {
                    state.pageState = .loading(.refresh)
                } else if case .failed = state.pageState {
                    state.pageState = .loading(.refresh)
                } else {
                    state.pageState = .loading(.initial)
                }
                
                return .run { [simulateEmpty = state.simulateEmpty, simulateError = state.simulateError, previousData, filter = state.selectedFilter] send in
                    let requestType: NetworkRequestManager.RequestResult = simulateError ? .failure : (simulateEmpty ? .successWithEmpty : .success)
                    
                    do {
                        // 刷新时始终从第0页开始 / Always start from page 0 when refreshing
                        let data = try await NetworkRequestManager.simulateListRequest(
                            page: 0,
                            requestType: requestType,
                            filterOption: filter
                        )
                        await send(.dataResponse(.success(data), isLoadMore: false, previousData: previousData))
                    } catch {
                        await send(.dataResponse(.failure(error), isLoadMore: false, previousData: previousData))
                    }
                }
                
            case .loadMore:
                // 检查是否可以加载更多 / Check if can load more
                guard case let .loaded(data, loadMoreState) = state.pageState,
                      data.hasMorePages else {
                    return .none
                }
                
                // 允许从idle和failed状态加载更多 / Allow load more from idle and failed states
                switch loadMoreState {
                case .idle, .failed:
                    state.pageState = .loaded(data, .loading)
                    // 加载更多时显示遮罩层 / Show overlay during load more
                    state.showLoadingOverlay = true
                case .loading, .noMore:
                    return .none
                }
                
                return .run { [nextPage = data.currentPage + 1, simulateError = state.simulateError, filter = state.selectedFilter] send in
                    let requestType: NetworkRequestManager.RequestResult = simulateError ? .failure : .success
                    
                    do {
                        let newData = try await NetworkRequestManager.simulateListRequest(
                            page: nextPage,
                            requestType: requestType,
                            filterOption: filter
                        )
                        await send(.dataResponse(.success(newData), isLoadMore: true, previousData: nil))
                    } catch {
                        await send(.dataResponse(.failure(error), isLoadMore: true, previousData: nil))
                    }
                }
                
            case let .dataResponse(result, isLoadMore, _):
                // 数据响应后隐藏遮罩层 / Hide overlay after data response
                state.showLoadingOverlay = false
                state.isChangingFilter = false
                
                switch result {
                case let .success(newData):
                    // 清除刷新错误信息 / Clear refresh error info
                    state.refreshErrorInfo = nil
                    
                    if isLoadMore {
                        // 追加新数据 / Append new items for load more
                        if case let .loaded(existingData, _) = state.pageState {
                            var combinedData = existingData
                            combinedData.items.append(contentsOf: newData.items)
                            combinedData.currentPage = newData.currentPage
                            combinedData.hasMorePages = newData.hasMorePages
                            
                            let loadMoreState: ReduxPageState<ListData<MockItem>>.LoadMoreState = 
                                newData.hasMorePages ? .idle : .noMore
                            state.pageState = .loaded(combinedData, loadMoreState)
                        }
                    } else {
                        // 替换数据（初始加载或刷新）/ Replace data for initial load or refresh
                        // 刷新会重置所有数据，从第一页开始 / Refresh resets all data, starting from page 1
                        let loadMoreState: ReduxPageState<ListData<MockItem>>.LoadMoreState = 
                            newData.hasMorePages ? .idle : .noMore
                        state.pageState = .loaded(newData, loadMoreState)
                    }
                    
                case let .failure(error):
                    // 创建错误信息 / Create error info
                    let errorInfo = ReduxPageState<ListData<MockItem>>.ErrorInfo(
                        type: .networkConnection,
                        description: error.localizedDescription
                    )
                    
                    if isLoadMore {
                        // 保留现有数据，显示加载更多错误 / Keep existing data, show load more error
                        if case let .loaded(data, _) = state.pageState {
                            state.pageState = .loaded(data, .failed(errorInfo))
                        }
                    } else {
                        // 根据当前状态确定失败类型 / Determine failure type based on current state
                        // 检查是否是刷新操作 / Check if it's a refresh operation
                        let wasRefreshing = if case .loading(.refresh) = state.pageState { true } else { false }
                        
                        if wasRefreshing {
                            // 刷新失败时清空数据，显示错误视图 / Clear data on refresh failure, show error view
                            state.pageState = .failed(.refresh, errorInfo)
                            state.refreshErrorInfo = errorInfo
                        } else {
                            // 初始加载失败 / Initial load failed
                            state.pageState = .failed(.initial, errorInfo)
                        }
                    }
                }
                return .none
                
            case .toggleErrorSimulation:
                state.simulateError.toggle()
                return .none
                
            case .toggleEmptySimulation:
                state.simulateEmpty.toggle()
                state.simulateError = false  // 重置错误模拟 / Reset error simulation
                return .none
                
            case .retry:
                // 重试初始加载失败的情况 / Retry for initial load failure
                if case .failed(.initial, _) = state.pageState {
                    state.pageState = .idle
                    // 重试时也显示遮罩层 / Show overlay during retry
                    state.showLoadingOverlay = true
                    return .send(.onAppear)
                } else if case .failed(.refresh, _) = state.pageState {
                    // 刷新失败后重试 / Retry after refresh failure
                    state.pageState = .idle
                    state.showLoadingOverlay = true
                    return .send(.onAppear)
                }
                return .none
                
            case .toggleFilterDropdown:
                state.showFilterDropdown.toggle()
                return .none
                
            case let .selectFilter(filter):
                // 选择新的筛选条件 / Select new filter
                state.selectedFilter = filter
                state.showFilterDropdown = false
                
                // 切换筛选时显示加载遮罩 / Show loading overlay when changing filter
                state.isChangingFilter = true
                state.showLoadingOverlay = true  // 使用主遮罩层 / Use main loading overlay
                
                // 重新加载数据 / Reload data with new filter
                state.pageState = .idle
                return .send(.onAppear)
            }
        }
    }
}