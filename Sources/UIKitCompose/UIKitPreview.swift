//
//  UIKitPreview.swift
//  UIKitCompose
//
//  Created by chenbo on 2025/9/9.
//

import UIKit
import SwiftUI

/// UIView 包装器
public struct UIViewPreview<View: UIView>: UIViewRepresentable {

    public let view: View
    public let width: CGFloat?
    public let height: CGFloat?
    public let fixedSize: Bool

    public init(width: CGFloat? = nil, height: CGFloat? = nil, fixedSize: Bool = false, _ builder: @escaping () -> View) {
        self.view = builder()
        self.width = width
        self.height = height
        self.fixedSize = fixedSize
    }

    public func makeUIView(context: Context) -> View {
        return view
    }

    public func updateUIView(_ uiView: View, context: Context) {
        if fixedSize {
            // 固定尺寸模式：使用指定的宽高
            uiView.setContentHuggingPriority(.required, for: .horizontal)
            uiView.setContentHuggingPriority(.required, for: .vertical)
            uiView.setContentCompressionResistancePriority(.required, for: .horizontal)
            uiView.setContentCompressionResistancePriority(.required, for: .vertical)
        } else {
            // 自适应模式：根据内容大小自适应
            uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
    }

    @available(iOS 16.0, *)
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: View, context: Context) -> CGSize? {
        if fixedSize {
            // 固定尺寸模式：返回指定的宽高
            return CGSize(
                width: width ?? proposal.width ?? UIView.layoutFittingExpandedSize.width,
                height: height ?? proposal.height ?? UIView.layoutFittingExpandedSize.height
            )
        } else {
            // 自适应模式：根据内容计算大小
            let targetSize = CGSize(
                width: width ?? proposal.width ?? UIView.layoutFittingExpandedSize.width,
                height: height ?? proposal.height ?? UIView.layoutFittingExpandedSize.height
            )
            let size = uiView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: width != nil ? .required : .fittingSizeLevel,
                verticalFittingPriority: height != nil ? .required : .fittingSizeLevel
            )
            return CGSize(
                width: width ?? size.width,
                height: height ?? size.height
            )
        }
    }
}

/// UIViewController 包装器
public struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {

    public let viewController: ViewController

    public init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    public func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }

    public func updateUIViewController(_ uiViewController: ViewController, context: Context) {

    }
}
