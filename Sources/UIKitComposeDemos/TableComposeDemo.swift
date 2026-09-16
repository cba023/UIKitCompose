//
//  TableComposeDemo.swift
//  UIKitCompose
//
//  Demo：TableProxy + TableBuilder 声明式配置 TableView
//  参考原工程 DrinkRecordsAlert 的真实用法：多 Section、Header 复用、空态分支、点击刷新
//

import UIKit
import SwiftUI
import SnapKit
import UIKitCompose

// MARK: - Cell（自身也用视图 DSL 搭建）

final class TodoDemoCell: UITableViewCell {

    private let checkView = UIView().then {
        $0.layer.cornerRadius = 9
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.systemTeal.cgColor
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
    }

    private let detailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.buildSubviews {
            ViewL(self.checkView) { make in
                make.leading.equalTo(16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(18)
            }
            ViewL(stackView: .instance(axis: .vertical, spacing: 2)) { make in
                make.leading.equalTo(self.checkView.snp.trailing).offset(10)
                make.trailing.equalTo(-16)
                make.centerY.equalToSuperview()
            } content: {
                StackL(self.titleLabel)
                StackL(self.detailLabel)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(title: String, detail: String, done: Bool) {
        detailLabel.text = detail
        checkView.backgroundColor = done ? .systemTeal : .clear
        if done {
            titleLabel.attributedText = NSAttributedString(
                string: title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.tertiaryLabel,
                ]
            )
        } else {
            titleLabel.attributedText = NSAttributedString(string: title)
        }
    }
}

// MARK: - Section Header

final class TodoDemoHeader: UITableViewHeaderFooterView {

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .semibold)
        $0.textColor = .secondaryLabel
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.buildSubviews {
            ViewL(self.titleLabel) { make in
                make.leading.equalTo(16)
                make.trailing.equalTo(-16)
                make.bottom.equalTo(-4)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(_ text: String) {
        titleLabel.text = text
    }
}

// MARK: - 演示页面

/// 可直接运行的 Table DSL 演示页（Example App 的第二个 Tab）
public final class TableComposeDemoViewController: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct Todo {
        let title: String
        let detail: String
        var done: Bool
    }

    private var groups: [(title: String, items: [Todo])] = [
        ("今天", [
            .init(title: "读完 UIKitCompose README", detail: "预计 10 分钟", done: true),
            .init(title: "用 ViewL 重构首页卡片", detail: "顺手删掉三层嵌套闭包", done: false),
        ]),
        ("本周", [
            .init(title: "把 TableProxy 接入设置页", detail: "支持空态和动态行", done: false),
            .init(title: "试试 autoCellHeight 自动行高", detail: "复杂内容也能撑开", done: false),
            .init(title: "发一个 0.1.0 tag", detail: "Changelog 写清楚 Then 协议", done: false),
        ]),
    ]

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .systemGroupedBackground
    }

    /// 通过 rebuildCallback 惰性取最新 builder，之后只需调用 reloadData()
    private lazy var tableProxy = TableProxy(tableView) { [weak self] in
        self?.buildTable()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo List"
        view.backgroundColor = .systemGroupedBackground
        view.buildSubviews {
            ViewL(tableView) { make in
                make.edges.equalToSuperview()
            }
        }
        tableProxy.reloadData()
    }

    private func buildTable() -> TableBuilder {
        TableBuilder {
            // for-in 动态生成多个 Section
            for (section, group) in groups.enumerated() {
                TableBuilder.Section(
                    headerHeight: 32,
                    headerReuse: .anyClass(TodoDemoHeader.self, { [weak self] tableView, sec, header in
                        header.render(self?.groups[sec].title ?? "")
                    })
                ) {
                    // 空态分支
                    if group.items.isEmpty {
                        TableBuilder.Row(cellHeight: 44, cellType: UITableViewCell.self) { _, _, cell in
                            cell.textLabel?.text = "这一组还没有条目"
                            cell.textLabel?.textAlignment = .center
                            cell.textLabel?.textColor = .secondaryLabel
                        }
                    }
                    for todo in group.items {
                        TableBuilder.Row(cellHeight: 56, cellType: TodoDemoCell.self) { _, _, cell in
                            cell.render(title: todo.title, detail: todo.detail, done: todo.done)
                        } didSelectRowAtIndexPath: { [weak self] _, indexPath, _ in
                            self?.groups[indexPath.section].items[indexPath.row].done.toggle()
                            self?.tableProxy.reloadData()
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    UIViewControllerPreview {
        UINavigationController(rootViewController: TableComposeDemoViewController())
    }
    .ignoresSafeArea()
}
