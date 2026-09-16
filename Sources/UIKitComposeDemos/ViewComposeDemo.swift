//
//  ViewComposeDemo.swift
//  UIKitCompose
//
//  Demo：then + 视图 DSL（buildSubviews + ViewL）+ 栈视图 DSL（StackL）
//  参考原工程 BRHomeNutrientsMacroItemV2 / DrinkRecordsAlert 的真实用法
//

import UIKit
import SwiftUI
import SnapKit
import UIKitCompose

/// 用户信息卡片：演示嵌套布局、条件子视图、动态刷新 arrangedSubviews
final class UserCardDemoView: UIView {

    private let avatarView = UIImageView().then {
        $0.image = UIImage(systemName: "person.crop.circle.fill")
        $0.tintColor = .systemTeal
        $0.contentMode = .scaleAspectFit
    }

    private let nameLabel = UILabel().then {
        $0.text = "UIKitCompose"
        $0.font = .boldSystemFont(ofSize: 16)
    }

    private let descLabel = UILabel().then {
        $0.text = "用 @resultBuilder 声明式搭建 UIKit 界面"
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
    }

    private let badgeLabel = UILabel().then {
        $0.text = "VIP"
        $0.font = .boldSystemFont(ofSize: 10)
        $0.textColor = .white
        $0.backgroundColor = .systemOrange
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }

    private let followButton = UIButton(type: .system).then {
        $0.setTitle("关注", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        $0.backgroundColor = .systemTeal
        $0.layer.cornerRadius = 12
    }

    private let tagStack = UIStackView.instance(axis: .horizontal, spacing: 6)

    init(isVIP: Bool) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemGroupedBackground

        buildSubviews {
            // 栈视图用 ViewL(stackView:) 嵌入普通视图层级
            ViewL(stackView: .instance(axis: .horizontal, alignment: .center, spacing: 12,
                                       insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))) { make in
                make.edges.equalToSuperview()
            } content: {
                StackL(self.avatarView, width: 48, height: 48)             // 固定子项尺寸
                // 栈里嵌栈
                StackL(stackView: .instance(axis: .vertical, spacing: 2)) {
                    StackL(self.nameLabel)
                    StackL(self.descLabel)
                    StackL(stackView: self.tagStack)
                }
                if isVIP {                                                 // 条件子视图
                    StackL(self.badgeLabel)
                }
                StackL(UIView())                                           // 弹性占位，把按钮推到最右
                StackL(self.followButton)
            }
        }

        updateTags(["声明式", "SnapKit", "轻量"])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 动态刷新：先清空再重建 arrangedSubviews
    func updateTags(_ tags: [String]) {
        tagStack.cleanArrangedSubviews()
        tagStack.buildArrangedSubviews {
            for tag in tags {                                              // for-in 循环
                StackL(tagLabel(tag))
            }
        }
    }

    private func tagLabel(_ text: String) -> UILabel {
        UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 11)
            $0.textColor = .secondaryLabel
            $0.backgroundColor = .systemFill
            $0.textAlignment = .center
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
    }
}

/// 可直接运行的视图 DSL 演示页（Example App 的第一个 Tab）
public final class ViewComposeDemoViewController: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "视图 DSL"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        view.buildSubviews {
            ViewL(stackView: .instance(axis: .vertical, alignment: .center, spacing: 20)) { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            } content: {
                StackL(UserCardDemoView(isVIP: true), width: 320)
                StackL(UserCardDemoView(isVIP: false), width: 320)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack(spacing: 20) {
        UIViewPreview(width: 320, height: 88, fixedSize: true) {
            UserCardDemoView(isVIP: true)
        }
        UIViewPreview(width: 320, height: 88, fixedSize: true) {
            UserCardDemoView(isVIP: false)
        }
    }
    .padding()
}
