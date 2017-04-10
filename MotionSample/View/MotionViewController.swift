//
//  MotionViewController.swift
//  MotionSample
//
//  Created by Hachibe on 2017/04/10.
//  Copyright © 2017年 Masanori. All rights reserved.
//

import UIKit
import CoreMotion

class MotionViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet private var stationaryLabel: UILabel!
    @IBOutlet private var walkingLabel: UILabel!
    @IBOutlet private var runningLabel: UILabel!
    @IBOutlet private var automotiveLabel: UILabel!
    @IBOutlet private var cyclingLabel: UILabel!
    @IBOutlet private var unknownLabel: UILabel!
    @IBOutlet private var confidenceLabel: UILabel!
    
    private let logFileManager = LogFileManager.sharedInstance
    private var motionActivityManager: CMMotionActivityManager?
    /// ログ書き込みに失敗したら1度だけアラートを表示させる
    private var isAppendLogError = false
    /// バックグラウンドで更新されたデータをフォアグランドに戻った時にviewへ反映できるよう取っておく
    private var bgActivity: CMMotionActivity?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationWillEnterForeground(_:)),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CMMotionActivityManager.isActivityAvailable() {
            // viewDidLoadだとalertが表示されないため、ここで処理する
            let alertController = UIAlertController(title: "MotionActivity未サポート",
                                                    message: "MotionActivityのデータを取得するには、M7コプロセッサを搭載した端末(iPhone5s以上)が必要です",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        motionActivityManager = CMMotionActivityManager()
        motionActivityManager?.startActivityUpdates(to: OperationQueue(), withHandler: { [weak self] (motionActivity: CMMotionActivity?) -> Void in
            guard let activity = motionActivity, let `self` = self else {
                print("didUpdateMotionActivity *** no data ***")
                return
            }
            
            print("didUpdateMotionActivity date: \(activity.startDate)")
            
            if UIApplication.shared.applicationState == .background {
                // フォアグランドに戻った時に反映できるよう取っておく
                self.bgActivity = activity
            } else {
                self.bgActivity = nil
                // viewへの反映はメインスレッドで行う
                DispatchQueue.main.async(execute: {
                    self.updateViews(activity)
                })
            }
            
            // ログ書き込み
            do {
                try self.logFileManager.appendLog(activity: activity)
            } catch let error as NSError {
                if !self.isAppendLogError && UIApplication.shared.applicationState != .background {
                    self.isAppendLogError = true
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "ログ書き込みエラー",
                                                                message: "空き容量不足などが考えられます。アプリを再インストールするなどして、ログを削除してください。\n\n\(error)",
                            preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
            }
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    func applicationWillEnterForeground(_ notification: NSNotification?) {
        if let activity = bgActivity {
            // バックグラウンドで更新されたデータをviewへ反映する
            print("updateLastBackgroundMotionActivity date: \(activity.startDate)")
            updateViews(activity)
            bgActivity = nil
        }
    }
    
    private func updateViews(_ activity: CMMotionActivity) {
        stationaryLabel.textColor = activity.stationary.color
        walkingLabel.textColor = activity.walking.color
        runningLabel.textColor = activity.running.color
        automotiveLabel.textColor = activity.automotive.color
        cyclingLabel.textColor = activity.cycling.color
        unknownLabel.textColor = activity.unknown.color
        
        confidenceLabel.text = activity.confidence.description
    }
}
