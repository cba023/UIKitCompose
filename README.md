# UIKitCompose

基于 `@resultBuilder` 的 UIKit 声明式布局库。用 Swift DSL 声明视图层级、栈布局和 `UITableView` 配置，约束基于 [SnapKit](https://github.com/SnapKit/SnapKit)，让 UIKit 拥有接近 SwiftUI 的书写体验。

```swift
view.buildSubviews {
    ViewL(stackView: .instance(axis: .vertical, spacing: 8)) { make in
        make.edges.equalToSuperview().inset(16)
    } content: {
        StackL(titleLabel)
        StackL(detailLabel)
    }
}
```

## 特性

- **视图 DSL**：`buildSubviews` + `ViewL` 声明视图层级与 SnapKit 约束，子视图统一先添加后约束，避免跨层引用约束的时序问题
- **栈视图 DSL**：`UIStackView.instance` 快速创建栈视图，`StackL` 支持子项定宽高、自定义间距与任意层级嵌套
- **TableView DSL**：`TableProxy` + `TableBuilder` 把 dataSource / delegate 收敛为一份声明式配置，支持 `if` / `for` 动态行、Cell 与 Header/Footer 复用、自动行高
- **Then**：通用"申请作用域"协议，任意类型都能在闭包中配置自身并原样返回
- **SwiftUI 预览**：`UIViewPreview` / `UIViewControllerPreview` 包装器，直接在 Xcode Canvas 实时预览 UIKit 界面

## 环境要求

- iOS 14.0+
- Swift 5.9+
- SnapKit 6.0+

## 安装

Xcode：`File → Add Package Dependencies…`，填入本仓库地址。

或在 `Package.swift` 中手动添加：

```swift
dependencies: [
    .package(url: "https://github.com/cba023/UIKitCompose.git", from: "0.1.0"),
],
targets: [
    .target(
        name: "UIKitComposeDemo",
        dependencies: [.product(name: "UIKitCompose", package: "UIKitCompose")]
    ),
]
```

## 使用指南

### 1. Then —— 申请作用域

遵循 `Then` 协议的类型（`UIView` 及其子类已默认遵循）可以在闭包中配置自身：

```swift
let label = UILabel().then {
    $0.text = "标题"
    $0.font = .boldSystemFont(ofSize: 16)
    $0.textColor = .label
}
```

闭包参数是 `Self`，编译期就是实例的真实类型，无需向下转型。自定义类型一行代码即可获得同样能力：

```swift
extension MyConfig: Then {}
```

### 2. 视图 DSL：buildSubviews + ViewL

`ViewL(子视图) { 约束 }` 声明一个子视图，`content:` 继续嵌套它的子视图：

```swift
self.buildSubviews {
    ViewL(progressBgView) { make in
        make.height.equalTo(40)
        make.leading.trailing.bottom.equalToSuperview()
    } content: {
        ViewL(progressView) { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
    }
    ViewL(titleLabel) { make in
        make.centerX.equalToSuperview()
        make.top.equalTo(22.5)
    }
}
```

要点：

- 所有子视图**先统一 addSubview、再统一加约束**，跨层级引用的约束也不会有时序问题
- 栈视图嵌入普通视图层级时使用 `ViewL(stackView: xxx) { ... }`，其 `content:` 里放 `StackL`

### 3. 栈视图 DSL：UIStackView.instance + StackL

```swift
contentView.buildSubviews {
    ViewL(stackView: .instance(
        axis: .horizontal, spacing: 10,
        insets: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    )) { make in
        make.edges.equalToSuperview()
    } content: {
        StackL(iconView, width: 40, height: 40)                        // 固定子项尺寸
        StackL(stackView: .instance(axis: .vertical, spacing: 2)) {    // 栈里嵌栈
            StackL(titleLabel)
            StackL(detailLabel)
        }
        StackL(UIView())                                               // 弹性占位
        StackL(moreButton, afterSpacing: 8)                            // 该子项后面追加 8pt 间距
    }
}
```

### 4. 条件与循环

两种 Builder 都支持 `if` / `else` 与 `for-in`，UI 随数据声明：

```swift
stack.buildArrangedSubviews {
    if list.isEmpty {
        StackL(emptyLabel)
    } else {
        for record in list {
            StackL(recordCell(for: record))
        }
    }
}
```

### 5. TableView DSL：TableProxy + TableBuilder

把整张表变成一段声明式配置，数据变化时重新 `rebuild` / `reloadData` 即可：

```swift
private lazy var tableProxy = TableProxy(tableView) { [weak self] in
    self?.buildTable()   // 每次 reloadData() 都会重新执行，始终拿到最新数据
}

func rebuildTable() {
    tableProxy.rebuild(TableBuilder {
        TableBuilder.Section(headerHeight: 44, headerReuse: .anyClass(HeaderView.self, { tableView, section, header in
            header.render("今日喝水记录")
        })) {
            if list.isEmpty {
                TableBuilder.Row(cellHeight: 141, cellType: PlaceholderCell.self) { _, _, _ in }
            } else {
                for record in list {
                    TableBuilder.Row(cellHeight: 80, cellType: RecordCell.self) { _, _, cell in
                        cell.reload(record)
                    } didSelectRowAtIndexPath: { tableView, indexPath, cell in
                        // 处理点击
                    }
                }
            }
        }
    })
}
```

常用能力速览：

| API | 说明 |
| --- | --- |
| `Row(cellHeight:autoCellHeight:cellType:reuseType:)` | 指定行高；`autoCellHeight: true` 时自动行高 |
| `Section(headerHeight:autoHeaderHeight:headerReuse:footerHeight:…)` | Section 头尾配置，`headerReuse` 支持 `.anyClass` / `.nibClass` 复用 |
| `tableView.tb.dequeueReusableCell(anyClass:)` / `(nibClass:)` | 按类名自动注册、复用 Cell 与 Header/Footer |
| `tableProxy.appendRowsToLastSection { … }` | 向最后一个 Section 追加行（适合分页加载） |
| `tableProxy.didSelectRow / willDisplay / didScroll / canEditRow / commitEdit …` | 滚动、编辑等事件统一挂在 proxy 上 |

### 6. SwiftUI 实时预览

```swift
import SwiftUI

@available(iOS 17.0, *)
#Preview {
    UIViewPreview(width: 320, height: 88, fixedSize: true) {
        UserCardView(isVIP: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    UIViewControllerPreview {
        UINavigationController(rootViewController: TableDemoViewController())
    }
    .ignoresSafeArea()
}
```

## Demo

仓库自带**可直接运行**的示例 App（Tab 形式展示两个页面）：

```bash
open UIKitCompose/Example/UIKitComposeDemo.xcodeproj
# 选中 UIKitComposeDemo scheme，Cmd+R 运行到模拟器即可
```

| Tab | 源文件 | 内容 |
| --- | --- | --- |
| 视图 DSL | `Sources/UIKitComposeDemos/ViewComposeDemo.swift` | `then` + 视图/栈视图 DSL：嵌套布局、条件子视图、动态刷新 arrangedSubviews |
| Table DSL | `Sources/UIKitComposeDemos/TableComposeDemo.swift` | Table DSL：多 Section、Header 复用、空态分支、点击后整体刷新 |

演示页本体放在包的 `UIKitComposeDemos` target 中，Xcode 打开 `Package.swift` 后在 Canvas 里也能实时预览（需 iOS 17+）。

## License

MIT
