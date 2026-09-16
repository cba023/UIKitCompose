//
//  ResultBuilderRule.swift
//  UIKitCompose
//
//  Created by chenbo on 2025/8/15.
//

import Foundation

public protocol ResultBuilderRule {

    associatedtype Base

    /// 空闭包
    static func buildBlock() -> [Base]

    /// 多元素叠加
    static func buildBlock(_ components: Base...) -> [Base]

    /// 多元素数组合
    static func buildBlock(_ components: [Base]...) -> [Base]

    /// 表达式支持
    static func buildExpression(_ expression: Base) -> [Base]

    /// if else语句支持 - if
    static func buildEither(first component: [Base]) -> [Base]

    /// if else语句支持 - else
    static func buildEither(second component: [Base]) -> [Base]

    /// if语句支持
    static func buildOptional(_ component: [Base]?) -> [Base]

    /// for循环
    static func buildArray(_ components: [[Base]]) -> [Base]

}

extension ResultBuilderRule {

    public static func buildBlock() -> [Base] {
        []
    }

    public static func buildBlock(_ components: Base...) -> [Base] {
        components.map { $0 }
    }

    public static func buildBlock(_ components: [Base]...) -> [Base] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Base) -> [Base] {
        [expression]
    }

    public static func buildEither(first component: [Base]) -> [Base] {
        component
    }

    public static func buildEither(second component: [Base]) -> [Base] {
        component
    }

    public static func buildOptional(_ component: [Base]?) -> [Base] {
        component ?? []
    }

    public static func buildArray(_ components: [[Base]]) -> [Base] {
        components.flatMap { $0 }
    }

}
