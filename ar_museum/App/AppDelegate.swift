//
//  AppDelegate.swift
//  ar_museum
//
//  Created by ConnHo on 2025/3/22.
//

import UIKit
import SwiftUI
import RealityKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 创建 SwiftUI 视图
        let contentView = ContentView()
        // 使用 UIHostingController 作为窗口的根视图控制器
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // 当应用程序即将从活动状态转为非活动状态时调用
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 使用此方法释放共享资源，保存用户数据，使计时器失效，并存储足够的应用程序状态信息
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // 作为从后台到活动状态转换的一部分调用
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // 重新启动应用程序处于非活动状态时暂停的任务
    }
}

