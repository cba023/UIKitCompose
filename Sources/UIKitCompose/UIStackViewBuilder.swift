//
//  UIStackViewBuilder.swift
//  UIKitCompose
//
//  Created by Calender on 2025/8/28.
//

import UIKit

extension UIStackView {

    /// 创建实例
    /// - Parameters:
    ///   - axis: 对称轴
    ///   - distribution: 布局形式
    ///   - alignment: 对齐
    ///   - spacing: 间距
    ///   - insets: 缩进
    /// - Returns: 生成的实例
    public static func instance(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat? = nil, insets: UIEdgeInsets? = nil ) -> UIStackView {
        let val = UIStackView()
        val.axis = axis
        val.distribution = distribution
        val.alignment = alignment
        if let spacing {
            val.spacing = spacing
        }
        if let insets {
            val.isLayoutMarginsRelativeArrangement = true
            val.layoutMargins = insets
        }
        return val
    }
}

// 定义ResultBuilder用于构建栈视图内容
@resultBuilder
public struct UIStackViewBuilder: ResultBuilderRule {
    public typealias Base = UIStackViewLayoutWrapper
}

extension UIStackView {

    /// 移除所有的排列子视图
    public func cleanArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // 动态更新子视图
    public func buildArrangedSubviews(@UIStackViewBuilder content: () -> [UIStackViewLayoutWrapper]) {
        for (_, x) in content().enumerated() {
            let view = x.view
            addArrangedSubview(view)
            if let afterSpacing = x.afterSpacing {
                setCustomSpacing(afterSpacing, after: view)
            }
            // 先把子视图都添加上
            if let stack = view as? UIStackView {
                stack.buildArrangedSubviews(content: x.content ?? {[]})
            } else {
                view.buildSubviews(content: x.viewContent ?? {[]})
            }
            // 再设置约束
            if x.width != nil || x.height != nil {
                view.snp.makeConstraints { make in
                    if let width = x.width {
                        make.width.equalTo(width)
                    }
                    if let height = x.height {
                        make.height.equalTo(height)
                    }
                }
            }
        }
    }
}

/// UIStackView子视图包装器UIStackViewLayoutWrapper的简写
public typealias StackL = UIStackViewLayoutWrapper

/// UIStackView子视图包装器
public struct UIStackViewLayoutWrapper {
    /// 子视图
    public private(set) var view: UIView
    /// 宽度
    public private(set) var width: CGFloat?
    /// 高度
    public private(set) var height: CGFloat?
    /// 子视图后方的间距
    public private(set) var afterSpacing: CGFloat?

    public private(set) var content: (() -> [UIStackViewLayoutWrapper])?

    public private(set) var viewContent: (() -> [UIViewLayoutWrapper])?

    public init(_ view: UIView, width: CGFloat? = nil, height: CGFloat? = nil, afterSpacing: CGFloat? = nil, @UIViewBuilder content: @escaping () -> [UIViewLayoutWrapper] = {[]}) {
        self.view = view
        if let width {
            self.width = width
        }
        if let height {
            self.height = height
        }
        if let afterSpacing {
            self.afterSpacing = afterSpacing
        }
        self.viewContent = content
    }

    public init(stackView: UIStackView, width: CGFloat? = nil, height: CGFloat? = nil, afterSpacing: CGFloat? = nil, @UIStackViewBuilder content: @escaping (() -> [UIStackViewLayoutWrapper]) = {[]}) {
        self.view = stackView
        if let width {
            self.width = width
        }
        if let height {
            self.height = height
        }
        if let afterSpacing {
            self.afterSpacing = afterSpacing
        }
        self.content = content
    }
}
