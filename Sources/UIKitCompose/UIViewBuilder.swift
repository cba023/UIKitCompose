//
//  UIViewBuilder.swift
//  UIKitCompose
//
//  Created by Calender on 2025/8/28.
//

import UIKit
import SnapKit

// 定义ResultBuilder用于构建视图内容
@resultBuilder
public struct UIViewBuilder: ResultBuilderRule {
    public typealias Base = UIViewLayoutWrapper
}

public protocol Then {}

public extension Then {

    /// 申请作用域
    func then(_ callback: (_ it: Self) -> ()) -> Self {
        callback(self)
        return self
    }
}

extension UIView: Then {}

extension UIView {

    /// 批量添加子视图
    public func buildSubviews(@UIViewBuilder content: () -> [UIViewLayoutWrapper]) {
        var wrappers: [(UIView, (_ make: ConstraintMaker) -> Void, (() -> [UIViewLayoutWrapper])?, (() -> [UIStackViewLayoutWrapper])?)] = []
        /// 把构造器的子视图添添加到父视图,用数组暂存
        for (_, x) in content().enumerated() {
            let view = x.view
            self.addSubview(view)
            wrappers.append((view, x.snpConstraints, x.content, x.stackContent))
        }
        // 统一设置约束保证约束有效且能避免闪退
        for (_, x) in wrappers.enumerated() {
            let view = x.0
            if let stack = view as? UIStackView {
                stack.buildArrangedSubviews(content: x.3 ?? {[]})
            } else {
                view.buildSubviews(content: x.2 ?? {[]})
            }
            view.snp.makeConstraints(x.1)
        }
    }
}

/// UIView子视图包装器UIViewLayoutWrapper的简写
public typealias ViewL = UIViewLayoutWrapper

/// UIView视图子视图包装器
public struct UIViewLayoutWrapper {

    public private(set) var view: UIView

    public private(set) var snpConstraints: (_ make: ConstraintMaker) -> Void

    public private(set) var content: (() -> [UIViewLayoutWrapper])?

    public private(set) var stackContent: (() -> [UIStackViewLayoutWrapper])?

    public init(_ view: UIView, _ snpConstraints: @escaping (_ make: ConstraintMaker) -> Void, @UIViewBuilder content: @escaping () -> [UIViewLayoutWrapper] = {[]}) {
        self.view = view
        self.snpConstraints = snpConstraints
        self.content = content
    }

    public init(stackView: UIStackView, _ snpConstraints: @escaping (_ make: ConstraintMaker) -> Void, @UIStackViewBuilder content: @escaping () -> [UIStackViewLayoutWrapper] = {[]}) {
        self.view = stackView
        self.snpConstraints = snpConstraints
        self.stackContent = content
    }
}
