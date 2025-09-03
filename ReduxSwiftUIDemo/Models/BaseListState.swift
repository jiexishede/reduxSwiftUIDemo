//
//  BaseListState.swift
//  ReduxSwiftUIDemo
//
//  Base state for list views with pagination
//

import Foundation

struct ListData<Item: Identifiable & Equatable>: Equatable {
    var items: [Item]
    var currentPage: Int
    var hasMorePages: Bool
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    static func empty<T: Identifiable & Equatable>() -> ListData<T> {
        ListData<T>(items: [], currentPage: 0, hasMorePages: false)
    }
}

// MARK: - Order Status Enum
// 订单状态枚举 / Order Status Enum
enum OrderStatus: String, CaseIterable, Equatable {
    case pending = "待处理"        // Pending
    case processing = "处理中"      // Processing
    case shipped = "已发货"         // Shipped
    case delivered = "已送达"       // Delivered
    case cancelled = "已取消"       // Cancelled
    case completed = "已完成"       // Completed
    
    var englishName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .processing: return "blue"
        case .shipped: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        case .completed: return "gray"
        }
    }
    
    var systemImage: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "gearshape.2"
        case .shipped: return "shippingbox"
        case .delivered: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.seal"
        }
    }
}

// MARK: - Mock Data Item
struct MockItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: Date
    let orderStatus: OrderStatus  // 订单状态 / Order status
    let orderNumber: String       // 订单号 / Order number
    let amount: Double            // 金额 / Amount
    
    static func generateMockItems(page: Int, perPage: Int = 10, filterStatus: OrderStatus? = nil) -> [MockItem] {
        // 调整每页数量为10条 / Adjust items per page to 10
        let actualPerPage = 10
        let allStatuses = OrderStatus.allCases
        
        var items: [MockItem] = []
        
        if let filterStatus = filterStatus {
            // 筛选特定状态时，生成该状态的10条数据 / Generate 10 items for specific status
            // 使用状态在枚举中的索引，避免 hashValue 溢出 / Use status index to avoid hashValue overflow
            let statusIndex = allStatuses.firstIndex(of: filterStatus) ?? 0
            let baseIndex = page * 1000 + statusIndex * 100
            
            for i in 0..<actualPerPage {
                let orderIndex = baseIndex + i
                items.append(MockItem(
                    id: UUID().uuidString,
                    title: "订单 #\(2000 + orderIndex) / Order #\(2000 + orderIndex)",
                    subtitle: "\(filterStatus.rawValue)订单详情 / \(filterStatus.englishName) order details",
                    timestamp: Date().addingTimeInterval(TimeInterval(-(page * actualPerPage + i) * 3600)),
                    orderStatus: filterStatus,
                    orderNumber: "ORD-\(String(format: "%06d", 2000 + orderIndex))",
                    amount: Double.random(in: 99...9999)
                ))
            }
        } else {
            // 全部订单时，混合生成各种状态，每页10条 / Generate mixed statuses for all orders, 10 per page
            let startIndex = page * actualPerPage
            
            for i in 0..<actualPerPage {
                let index = startIndex + i
                let status = allStatuses[index % allStatuses.count]
                
                items.append(MockItem(
                    id: UUID().uuidString,
                    title: "订单 #\(1000 + index) / Order #\(1000 + index)",
                    subtitle: "客户订单详情 / Customer order details",
                    timestamp: Date().addingTimeInterval(TimeInterval(-index * 3600)),
                    orderStatus: status,
                    orderNumber: "ORD-\(String(format: "%06d", 1000 + index))",
                    amount: Double.random(in: 99...9999)
                ))
            }
        }
        
        return items
    }
}