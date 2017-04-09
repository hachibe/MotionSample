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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CMMotionActivityManager.isActivityAvailable() {
            let alertController = UIAlertController(title: "MotionActivity未サポート",
                                                    message: "MotionActivityのデータを取得するには、M7コプロセッサを搭載した端末(iPhone5s以上)が必要です",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        motionActivityManager = CMMotionActivityManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motionActivityManager?.startActivityUpdates(to: OperationQueue.main, withHandler: { [weak self] (motionActivity: CMMotionActivity?) -> Void in
            DispatchQueue.main.async(execute: {
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
                
                self.logFileManager.appendLog(activity: activity)
            })
        })
    }
}
