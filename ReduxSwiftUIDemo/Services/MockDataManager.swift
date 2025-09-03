//
//  MockDataManager.swift
//  ReduxSwiftUIDemo
//
//  Mock data manager for loading local JSON files
//  本地JSON文件的模拟数据管理器
//

import Foundation

/// 模拟数据管理器 / Mock Data Manager
struct MockDataManager {
    
    // MARK: - Mock Data Models
    // 模拟数据模型 / Mock Data Models
    
    /// 用户模型 / User Model
    struct User: Codable, Identifiable, Equatable {
        let id: String
        let name: String
        let email: String
        let avatar: String
        let status: String
    }
    
    /// 产品模型 / Product Model
    struct Product: Codable, Identifiable, Equatable {
        let id: String
        let title: String
        let description: String
        let price: Double
        let category: String
    }
    
    /// 文章模型 / Article Model
    struct Article: Codable, Identifiable, Equatable {
        let id: String
        let title: String
        let content: String
        let author: String
        let date: String
    }
    
    /// 模拟数据容器 / Mock Data Container
    struct MockDataContainer: Codable {
        let users: [User]
        let products: [Product]
        let articles: [Article]
    }
    
    // MARK: - Data Loading
    // 数据加载 / Data Loading
    
    /// 加载模拟数据 / Load mock data
    static func loadMockData() -> MockDataContainer? {
        // 获取本地JSON文件路径 / Get local JSON file path
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json") else {
            print("⚠️ 找不到MockData.json文件 / MockData.json file not found")
            return nil
        }
        
        do {
            // 读取文件数据 / Read file data
            let data = try Data(contentsOf: url)
            // 解码JSON数据 / Decode JSON data
            let decoder = JSONDecoder()
            let container = try decoder.decode(MockDataContainer.self, from: data)
            return container
        } catch {
            print("❌ 解析MockData.json失败 / Failed to parse MockData.json: \(error)")
            return nil
        }
    }
    
    /// 生成分页的模拟数据 / Generate paginated mock data
    static func generatePagedMockItems(
        page: Int,
        perPage: Int = 10,
        totalItems: Int = 100
    ) -> [MockItem] {
        // 固定每页10条数据 / Fixed 10 items per page
        let actualPerPage = 10
        let startIndex = page * actualPerPage
        let endIndex = min(startIndex + actualPerPage, totalItems)
        
        guard startIndex < totalItems else { return [] }
        
        let allStatuses = OrderStatus.allCases
        
        return (startIndex..<endIndex).map { index in
            // 为每个订单分配不同的状态 / Assign different status to each order
            let status = allStatuses[index % allStatuses.count]
            
            return MockItem(
                id: UUID().uuidString,
                title: "订单 #\(1000 + index) / Order #\(1000 + index)",
                subtitle: "客户订单详情 / Customer order details - 第\(page + 1)页 / Page \(page + 1)",
                timestamp: Date().addingTimeInterval(TimeInterval(-index * 3600)),
                orderStatus: status,
                orderNumber: "ORD-\(String(format: "%06d", 1000 + index))",
                amount: Double.random(in: 99...9999)
            )
        }
    }
}