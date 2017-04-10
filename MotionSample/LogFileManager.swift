//
//  LogFileManager.swift
//  MotionSample
//
//  Created by Hachibe on 2017/04/10.
//  Copyright © 2017年 Masanori. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

class LogFileManager {
    
    static let sharedInstance = LogFileManager()
    
    var lastLocation: CLLocation?
    
    /// MotionActivityのデータを追記する
    func appendLog(activity: CMMotionActivity) throws {
        guard let `fileURL` = fileURL else {
            return
        }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(logString(activity).data(using: String.Encoding.shiftJIS)!)
        } catch let error as NSError {
            print("failed to append: \(error)")
            throw error
        }
    }
    
    // MARK: - Private
    
    private let fileURL: URL?
    
    private init() {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fileURL = nil
            print("failed to get document URL")
            return
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "MotionLog_\(formatter.string(from: Date())).csv"
        fileURL = documentURL.appendingPathComponent(fileName)
        print("log file URL: \(String(describing: fileURL))")
        
        do {
            let initialText = "Time,Stationary,Walking,Running,Automotive,Cycling,Unknown,Confidence,Lat,Lon,Accuracy\n"
            try initialText.write(to: fileURL!, atomically: true, encoding: String.Encoding.shiftJIS)
        } catch let error as NSError {
            print("failed to create file, error: \(error)")
        }
    }
    
    private func logString(_ activity: CMMotionActivity) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.sss"
        
        var logArray = [formatter.string(from: Date())]
        logArray.append(activity.stationary.mark)
        logArray.append(activity.walking.mark)
        logArray.append(activity.running.mark)
        logArray.append(activity.automotive.mark)
        logArray.append(activity.cycling.mark)
        logArray.append(activity.unknown.mark)
        logArray.append(activity.confidence.description)
        
        if let location = lastLocation {
            logArray.append("\(String(describing: location.coordinate.latitude))")
            logArray.append("\(String(describing: location.coordinate.longitude))")
            logArray.append("\(String(describing: location.horizontalAccuracy))")
        }
        
        return logArray.joined(separator: ",") + "\n"
    }
}
