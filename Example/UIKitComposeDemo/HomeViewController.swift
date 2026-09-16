//
//  HomeViewController.swift
//  UIKitComposeDemo
//
//  入口：Tab 切换两个演示页，页面本体来自 UIKitComposeDemos
//

import UIKit
import UIKitComposeDemos

final class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let viewDemo = UINavigationController(rootViewController: ViewComposeDemoViewController())
        viewDemo.tabBarItem = UITabBarItem(title: "视图 DSL", image: UIImage(systemName: "rectangle.3.group"), tag: 0)

        let tableDemo = UINavigationController(rootViewController: TableComposeDemoViewController())
        tableDemo.tabBarItem = UITabBarItem(title: "Table DSL", image: UIImage(systemName: "list.bullet.rectangle"), tag: 1)

        viewControllers = [viewDemo, tableDemo]
    }
}
