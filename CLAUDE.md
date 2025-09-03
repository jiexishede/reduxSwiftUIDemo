# CLAUDE.md - Project Guidelines
# CLAUDE.md - 项目指南

## Project Overview / 项目概述
This is a SwiftUI project using The Composable Architecture (TCA) pattern for state management.
这是一个使用 The Composable Architecture (TCA) 模式进行状态管理的 SwiftUI 项目。

## 📱 iOS Version Requirements / iOS 版本要求

### Minimum iOS Version: 15.0 / 最低 iOS 版本：15.0
- **This project only supports iOS 15.0 and above** / **本项目仅支持 iOS 15.0 及以上版本**
- **NO support for iOS 14 or below** / **不支持 iOS 14 或更低版本**

### Version Adaptation Rules / 版本适配规则
The code should only differentiate between two iOS versions:
代码只需区分两个 iOS 版本：

1. **iOS 15.0** - Use legacy SwiftUI APIs / 使用旧版 SwiftUI API
2. **iOS 16.0+** - Use modern SwiftUI APIs / 使用现代 SwiftUI API

### Implementation Example / 实现示例
```swift
// Correct version check / 正确的版本检查
if #available(iOS 16.0, *) {
    // iOS 16.0+ implementation / iOS 16.0+ 实现
    ModernView()
} else {
    // iOS 15.0 implementation / iOS 15.0 实现
    LegacyView()
}

// ❌ WRONG - Don't check for iOS 14 / 错误 - 不要检查 iOS 14
if #available(iOS 14.0, *) {
    // This should not exist / 这不应该存在
}
```

### Key API Differences / 主要 API 差异
- **iOS 16.0+**: NavigationStack, .refreshable modifier improvements / NavigationStack，.refreshable 修饰符改进
- **iOS 15.0**: NavigationView, basic .refreshable support / NavigationView，基础 .refreshable 支持

## 🚨 IMPORTANT: Auto-Build and Fix Rules / 重要：自动构建和修复规则

### Automatic Error Detection and Fixing / 自动错误检测和修复
When working on this project, the AI assistant MUST:
在处理此项目时，AI助手必须：

1. **Use command-line tools to build the project** / **使用命令行工具构建项目**
   ```bash
   swift build  # For Swift Package Manager / 用于 Swift Package Manager
   xcodebuild -project ReduxSwiftUIDemo.xcodeproj -scheme ReduxSwiftUIDemo -destination "platform=iOS Simulator,name=iPhone 16" build  # For Xcode project / 用于 Xcode 项目
   ```

2. **Automatically detect and fix compilation errors** / **自动检测和修复编译错误**
   - Run build command / 运行构建命令
   - Parse error messages / 解析错误信息
   - Show errors to user / 向用户显示错误
   - Automatically fix the errors / 自动修复错误
   - Re-run build until successful / 重新运行构建直到成功

3. **Error fixing workflow** / **错误修复工作流程**:
   ```
   构建项目 → 检测错误 → 显示错误给用户 → 自动修复 → 重新构建 → 直到成功
   Build project → Detect errors → Show errors to user → Auto-fix → Rebuild → Until success
   ```

### Example Auto-Fix Process / 自动修复流程示例
```bash
# 1. Build and capture errors / 构建并捕获错误
xcodebuild ... 2>&1 | grep -E "error:"

# 2. If errors found / 如果发现错误:
#    - Parse error location and type / 解析错误位置和类型
#    - Read the problematic file / 读取有问题的文件
#    - Apply appropriate fix / 应用适当的修复
#    - Save the file / 保存文件

# 3. Rebuild to verify fix / 重新构建以验证修复
xcodebuild ... 

# 4. Repeat until no errors / 重复直到没有错误
```

## 📝 Bilingual Comments Rule / 双语注释规则

### ALL comments in the project MUST be bilingual (Chinese + English)
### 项目中的所有注释必须是双语的（中文+英文）

#### File Headers / 文件头部
```swift
//
//  FileName.swift
//  ReduxSwiftUIDemo
//
//  File description in English
//  文件描述（中文）
//
```

#### Inline Comments / 内联注释
```swift
// This is a comment in English / 这是中文注释
let variable = "value"

/* Multi-line comment in English
   多行注释（中文） */
```

#### MARK Comments / MARK 注释
```swift
// MARK: - Section Name / 部分名称
// MARK: - Properties / 属性
// MARK: - Methods / 方法
```

#### Documentation Comments / 文档注释
```swift
/// Function description in English
/// 函数描述（中文）
/// - Parameters:
///   - param: Parameter description / 参数描述
/// - Returns: Return value description / 返回值描述
func exampleFunction(param: String) -> Bool {
    // Implementation / 实现
}
```

## Code Style Requirements / 代码风格要求

### SwiftLint Compliance / SwiftLint 合规性
- **MUST** strictly follow SwiftLint code standards / **必须**严格遵守 SwiftLint 代码标准
- Run `swiftlint` before committing any code / 提交任何代码前运行 `swiftlint`
- Fix all warnings and errors reported by SwiftLint / 修复 SwiftLint 报告的所有警告和错误

### SwiftUI View Structure Rules / SwiftUI 视图结构规则

#### Maximum Nesting Level: 2 / 最大嵌套级别：2
- SwiftUI view body closures must NOT exceed 2 levels of nesting with `{}`
- SwiftUI 视图 body 闭包的 `{}` 嵌套不得超过 2 级
- If a view requires more than 2 levels of nesting, it MUST be refactored into smaller components
- 如果视图需要超过 2 级嵌套，必须重构为更小的组件

#### View Decomposition Strategy / 视图分解策略
When refactoring views to comply with the 2-level nesting rule:
重构视图以符合 2 级嵌套规则时：

1. **Extract Complex Views** / **提取复杂视图**: Break down complex views into smaller, reusable components / 将复杂视图分解为更小的可重用组件
2. **Use Computed Properties** / **使用计算属性**: Extract view sections as private computed properties / 将视图部分提取为私有计算属性
3. **Create Subviews** / **创建子视图**: Create separate SwiftUI View structs for complex UI sections / 为复杂的 UI 部分创建单独的 SwiftUI View 结构体

### Examples / 示例

#### ❌ BAD - Exceeds 2 levels of nesting / 错误 - 超过 2 级嵌套:
```swift
struct BadView: View {
    var body: some View {
        VStack {                    // Level 1 / 第 1 级
            HStack {                // Level 2 / 第 2 级
                VStack {            // Level 3 - VIOLATION! / 第 3 级 - 违规！
                    Text("Bad")
                }
            }
        }
    }
}
```

#### ✅ GOOD - Properly refactored / 正确 - 正确重构:
```swift
struct GoodView: View {
    var body: some View {
        VStack {                    // Level 1 / 第 1 级
            headerSection           // Extracted to computed property / 提取到计算属性
            contentSection
        }
    }
    
    private var headerSection: some View {
        HStack {                    // Level 1 in extracted view / 提取视图中的第 1 级
            Text("Good")
        }
    }
    
    private var contentSection: some View {
        ContentSubview()            // Separate component / 独立组件
    }
}

struct ContentSubview: View {
    var body: some View {
        VStack {                    // Level 1 in subview / 子视图中的第 1 级
            Text("Content")
        }
    }
}
```

## Refactoring Checklist / 重构检查清单

When reviewing or writing SwiftUI code / 审查或编写 SwiftUI 代码时:

1. **Count nesting levels** / **计算嵌套级别** - Check all `{}` blocks in view body / 检查视图 body 中的所有 `{}` 块
2. **Identify violations** / **识别违规** - Mark any code exceeding 2 levels / 标记任何超过 2 级的代码
3. **Extract components** / **提取组件** - Create smaller, focused components / 创建更小、更专注的组件
4. **Name meaningfully** / **有意义的命名** - Use descriptive names for extracted views / 为提取的视图使用描述性名称
5. **Verify compliance** / **验证合规性** - Ensure refactored code meets all requirements / 确保重构的代码满足所有要求

## Component Size Guidelines / 组件大小指南

- **Single Responsibility** / **单一职责**: Each view should have one clear purpose / 每个视图应该有一个明确的目的
- **Line Count** / **行数**: View body should ideally be under 50 lines / 视图 body 理想情况下应少于 50 行
- **Readability** / **可读性**: Code should be easily scannable and understandable / 代码应该易于浏览和理解
- **Reusability** / **可重用性**: Extract common UI patterns into reusable components / 将常见的 UI 模式提取为可重用组件

## File Organization / 文件组织

```
ReduxSwiftUIDemo/
├── Models/           # Data models and types / 数据模型和类型
├── Features/         # TCA reducers and business logic / TCA reducers 和业务逻辑
├── Views/           # SwiftUI view components / SwiftUI 视图组件
│   ├── Components/  # Reusable UI components / 可重用的 UI 组件
│   └── Screens/     # Full screen views / 全屏视图
├── Services/        # Network and data services / 网络和数据服务
└── Resources/       # Assets and configuration / 资源和配置
```

## Testing Requirements / 测试要求

- Run `swift test` to execute all tests / 运行 `swift test` 执行所有测试
- Run `swiftlint` to check code style / 运行 `swiftlint` 检查代码风格
- Run `swift build` to verify compilation / 运行 `swift build` 验证编译

## Common SwiftLint Rules to Follow / 要遵循的常见 SwiftLint 规则

- **line_length**: Maximum 120 characters per line / 每行最多 120 个字符
- **file_length**: Files should not exceed 400 lines / 文件不应超过 400 行
- **type_body_length**: Types should not exceed 200 lines / 类型不应超过 200 行
- **function_body_length**: Functions should not exceed 40 lines / 函数不应超过 40 行
- **cyclomatic_complexity**: Functions should have low complexity (max 10) / 函数应具有低复杂性（最多 10）
- **nesting**: Types should not be nested more than 1 level deep / 类型嵌套不应超过 1 级
- **trailing_whitespace**: Remove all trailing whitespace / 删除所有尾随空格
- **vertical_whitespace**: Limit vertical whitespace to single empty lines / 将垂直空格限制为单个空行

## Commands to Run / 要运行的命令

```bash
# Check SwiftLint compliance / 检查 SwiftLint 合规性
swiftlint

# Auto-fix SwiftLint violations where possible / 尽可能自动修复 SwiftLint 违规
swiftlint --fix

# Build project / 构建项目
swift build

# Build with Xcode / 使用 Xcode 构建
xcodebuild -project ReduxSwiftUIDemo.xcodeproj -scheme ReduxSwiftUIDemo -destination "platform=iOS Simulator,name=iPhone 16" build

# Run tests / 运行测试
swift test
```

## Notes for AI Assistant / AI 助手注意事项

When modifying this project / 修改此项目时:
1. **ALWAYS check nesting levels in SwiftUI views** / **始终检查 SwiftUI 视图中的嵌套级别**
2. **ALWAYS refactor views exceeding 2 levels of nesting** / **始终重构超过 2 级嵌套的视图**
3. **ALWAYS run swiftlint after making changes** / **进行更改后始终运行 swiftlint**
4. **ALWAYS extract complex UI into smaller components** / **始终将复杂的 UI 提取为更小的组件**
5. **ALWAYS use bilingual comments (Chinese + English)** / **始终使用双语注释（中文+英文）**
6. **ALWAYS build project and auto-fix errors until successful** / **始终构建项目并自动修复错误直到成功**
7. **NEVER create deeply nested view hierarchies** / **永远不要创建深层嵌套的视图层次结构**
8. **NEVER submit code with compilation errors** / **永远不要提交有编译错误的代码**
9. **PREFER computed properties and separate view structs over inline nested views** / **优先使用计算属性和单独的视图结构体而不是内联嵌套视图**