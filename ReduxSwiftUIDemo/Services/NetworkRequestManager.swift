//
//  NetworkRequestManager.swift
//  ReduxSwiftUIDemo
//
//  Shared network request logic for list pages
//  共享的列表页面网络请求逻辑
//

import ComposableArchitecture
import Foundation

/// 网络请求管理器 / Network Request Manager
struct NetworkRequestManager {
    
    // MARK: - Request Result Type
    // 请求结果类型 / Request Result Type
    enum RequestResult {
        /// 成功 / Success
        case success
        /// 成功但返回空数据 / Success with empty data
        case successWithEmpty
        /// 失败 / Failure
        case failure
    }
    
    // MARK: - Network Error
    // 网络错误 / Network Error
    enum NetworkError: Error, LocalizedError {
        /// 请求失败 / Request failed
        case requestFailed(ReduxPageState<ListData<MockItem>>.ErrorType)
        /// 超时 / Timeout
        case timeout
        /// 无网络连接 / No internet connection
        case noInternet
        
        var errorDescription: String? {
            switch self {
            case .requestFailed(let type):
                return type.defaultDescription
            case .timeout:
                return ReduxPageState<ListData<MockItem>>.ErrorType.timeout.defaultDescription
            case .noInternet:
                return ReduxPageState<ListData<MockItem>>.ErrorType.networkConnection.defaultDescription
            }
        }
        
        /// 转换为ErrorInfo / Convert to ErrorInfo
        var errorInfo: ReduxPageState<ListData<MockItem>>.ErrorInfo {
            switch self {
            case .requestFailed(let type):
                return ReduxPageState<ListData<MockItem>>.ErrorInfo(type: type)
            case .timeout:
                return ReduxPageState<ListData<MockItem>>.ErrorInfo(type: .timeout)
            case .noInternet:
                return ReduxPageState<ListData<MockItem>>.ErrorInfo(type: .networkConnection)
            }
        }
    }
    
    // MARK: - Request Methods
    // 请求方法 / Request Methods
    
    /// 模拟列表请求 / Simulate list request
    /// - Parameters:
    ///   - page: 页码 / Page number
    ///   - perPage: 每页数量 / Items per page
    ///   - requestType: 请求类型 / Request type
    ///   - delay: 延迟时间 / Delay time
    /// - Returns: 列表数据 / List data
    static func simulateListRequest(
        page: Int,
        perPage: Int = 20,
        requestType: RequestResult = .success,
        delay: TimeInterval = 1.5
    ) async throws -> ListData<MockItem> {
        // 模拟网络延迟 / Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // 模拟不同的响应 / Simulate different responses
        switch requestType {
        case .success:
            // 生成模拟数据 / Generate mock data
            let totalItems = 100  // 总共100条数据 / Total 100 items
            let items = MockDataManager.generatePagedMockItems(
                page: page,
                perPage: perPage,
                totalItems: totalItems
            )
            // 计算是否还有更多页 / Calculate if has more pages
            let hasMore = (page + 1) * perPage < totalItems
            return ListData(items: items, currentPage: page, hasMorePages: hasMore)
            
        case .successWithEmpty:
            // 返回空数据 / Return empty data
            return ListData(items: [], currentPage: page, hasMorePages: false)
            
        case .failure:
            // 抛出错误 / Throw error
            throw NetworkError.requestFailed(.networkConnection)
        }
    }
    
    /// 带筛选的列表请求 / List request with filter
    static func simulateListRequest(
        page: Int,
        requestType: RequestResult = .success,
        filterOption: OrderFilterOption = .all
    ) async throws -> ListData<MockItem> {
        // 模拟网络延迟 / Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒 / 1.5 seconds
        
        // 根据请求类型返回不同结果 / Return different results based on request type
        switch requestType {
        case .success:
            // 根据筛选条件生成数据 / Generate data based on filter
            let items: [MockItem]
            switch filterOption {
            case .all:
                items = MockItem.generateMockItems(page: page, perPage: 10)
            case .status(let status):
                items = MockItem.generateMockItems(page: page, perPage: 10, filterStatus: status)
            case .noOrders:
                // 特殊筛选：无订单状态，返回空数据 / Special filter: no orders state, return empty
                items = []
            }
            
            return ListData(
                items: items,
                currentPage: page,
                hasMorePages: filterOption == .noOrders ? false : page < 4 // 最多5页 / Maximum 5 pages
            )
            
        case .successWithEmpty:
            return ListData(
                items: [],
                currentPage: page,
                hasMorePages: false
            )
            
        case .failure:
            throw NetworkError.requestFailed(.networkConnection)
        }
    }
}

// MARK: - Network Effect Helpers
// 网络请求Effect助手 / Network Effect Helpers
extension Effect where Action == Result<ListData<MockItem>, Error> {
    /// 创建网络请求Effect / Create network request effect
    static func networkRequest(
        page: Int,
        requestType: NetworkRequestManager.RequestResult = .success
    ) -> Effect<Action> {
        .run { send in
            do {
                let data = try await NetworkRequestManager.simulateListRequest(
                    page: page,
                    requestType: requestType
                )
                await send(.success(data))
            } catch {
                await send(.failure(error))
            }
        }
    }
}