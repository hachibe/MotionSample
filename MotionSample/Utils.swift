//
//  Utils.swift
//  MotionSample
//
//  Created by Hachibe on 2017/04/10.
//  Copyright © 2017年 Masanori. All rights reserved.
//

import UIKit
import CoreMotion

extension Bool {
    /// Bool値によって色を指定
    var color: UIColor {
        return self ? .red : .gray
    }
}

extension Bool {
    /// Bool値によって文字を指定
    var string: String {
        return self ? "○" : ""
    }
}

extension CMMotionActivityConfidence {
    var description: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Midium"
        case .high:
            return "High"
        }
    }
}
