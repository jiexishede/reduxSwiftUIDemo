# 错误处理测试计划 / Error Handling Test Plan

## 测试场景 / Test Scenarios

### 1. 下拉刷新错误 / Pull-to-Refresh Error
1. 进入 RefreshableListView 页面 / Enter RefreshableListView page
2. 打开 "模拟错误 / Simulate Error" 开关 / Toggle "Simulate Error" switch
3. 下拉刷新 / Pull to refresh
4. 验证显示错误横幅 / Verify error banner shows
5. 点击错误横幅中的"重试"按钮 / Click "Retry" button in error banner
6. 验证重新发起请求 / Verify request is retried

### 2. 加载更多错误 / Load More Error  
1. 加载初始数据成功 / Load initial data successfully
2. 滚动到底部 / Scroll to bottom
3. 打开 "模拟错误 / Simulate Error" 开关 / Toggle "Simulate Error" switch
4. 点击"加载更多" / Click "Load More"
5. 验证显示错误视图，包含错误详情 / Verify error view shows with error details
6. 点击"点击重试"按钮 / Click "Tap to retry" button
7. 验证重新发起加载更多请求 / Verify load more request is retried

### 3. 初始加载错误 / Initial Load Error
1. 打开 "模拟错误 / Simulate Error" 开关 / Toggle "Simulate Error" switch
2. 进入 RefreshableListView 页面 / Enter RefreshableListView page  
3. 验证显示初始错误视图 / Verify initial error view shows
4. 点击"重试"按钮 / Click "Retry" button
5. 验证重新发起初始加载请求 / Verify initial load request is retried

## 功能验证点 / Feature Verification Points

✅ 刷新错误时保留原有数据 / Keep existing data on refresh error
✅ 刷新错误显示可点击的错误横幅 / Show clickable error banner on refresh error
✅ 加载更多错误显示详细的错误视图 / Show detailed error view on load more error
✅ 所有错误视图都提供重试功能 / All error views provide retry functionality
✅ 错误信息使用枚举类型 / Error info uses enum types
✅ 双语显示（中文+英文）/ Bilingual display (Chinese + English)

## 实现的组件 / Implemented Components

1. **RefreshErrorView** - 刷新错误横幅视图 / Refresh error banner view
   - 位置：RefreshableListView.swift:310
   - 功能：显示刷新失败信息和重试按钮

2. **LoadMoreView** - 加载更多视图（包含错误状态）/ Load more view (with error state)
   - 位置：RefreshableListView.swift:519
   - 功能：显示加载更多各种状态，包括错误和重试

3. **InitialErrorView** - 初始加载错误视图 / Initial load error view
   - 位置：RefreshableListView.swift:393
   - 功能：显示初始加载失败信息和重试按钮

## 状态管理 / State Management

- `refreshErrorInfo` - 专门用于刷新错误的状态属性
- `ReduxPageState.ErrorInfo` - 错误信息结构体
- `ReduxPageState.ErrorType` - 错误类型枚举