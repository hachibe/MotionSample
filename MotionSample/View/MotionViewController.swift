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
    
    // MARK: - View Life Cycle
    
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
        motionActivityManager?.startActivityUpdates(to: OperationQueue.main, withHandler: { [weak self] (motionActivity: CMMotionActivity?) -> Void in
            guard let activity = motionActivity, let `self` = self else {
                return
            }
            
            self.stationaryLabel.textColor = activity.stationary.color
            self.walkingLabel.textColor = activity.walking.color
            self.runningLabel.textColor = activity.running.color
            self.automotiveLabel.textColor = activity.automotive.color
            self.cyclingLabel.textColor = activity.cycling.color
            self.unknownLabel.textColor = activity.unknown.color
            
            self.confidenceLabel.text = activity.confidence.description
            
            // ログ書き込み
            do {
                try self.logFileManager.appendLog(activity: activity)
            } catch let error as NSError {
                if !self.isAppendLogError {
                    self.isAppendLogError = true
                    let alertController = UIAlertController(title: "ログ書き込みエラー",
                                                            message: "空き容量不足などが考えられます。アプリを再インストールするなどして、ログを削除してください。\n\n\(error)",
                                                            preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
}
