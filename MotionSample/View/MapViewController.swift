//
//  MapViewController.swift
//  MotionSample
//
//  Created by Hachibe on 2017/04/10.
//  Copyright © 2017年 Masanori. All rights reserved.
//

import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet fileprivate var mapView: MKMapView!
    @IBOutlet private var currentLocationButton: UIButton!
    
    fileprivate let logFileManager = LogFileManager.sharedInstance
    fileprivate var locationManager: CLLocationManager!
    
    /// 現在地を設定済みかどうか
    var alreadyStartingCoordinateSet = false
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let tokyoStationCoodinate = CLLocationCoordinate2DMake(35.681382, 139.766084)
        mapView.region = MKCoordinateRegionMake(tokyoStationCoodinate, MKCoordinateSpanMake(0.1, 0.1))
        
        // 地図の下に隠れないように一番上に持ってくる
        self.view.bringSubview(toFront: currentLocationButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch CLLocationManager.authorizationStatus() {
        case .restricted, .denied:
            // viewDidLoadだとalertが表示されないため、ここで処理する
            let alertController = UIAlertController(title: "位置情報サービスがオフ",
                                                    message: "現在地を取得するために、位置情報サービスをオンにしてください",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    // MARK: - Action
    
    @IBAction func currentLocationButtonDidTouch(_ sender: UIButton) {
        if let location = mapView.userLocation.location {
            if CLLocationCoordinate2DIsValid(location.coordinate) {
                mapView.setCenter(location.coordinate, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "位置情報エラー",
                                                    message: "現在地が取得できていません",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    /// 位置更新の通知
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        guard let coordinate = location?.coordinate else {
            return
        }
        
        logFileManager.lastLocation = location
        
        if CLLocationCoordinate2DIsValid(coordinate) {
            // 初回の測位では現在地にフォーカスする
            if !alreadyStartingCoordinateSet {
                mapView.setRegion(MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
                alreadyStartingCoordinateSet = true
            }
        }
    }
    
    /// 許諾変更の通知
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization: \(status.rawValue)")
        switch status {
        case .authorizedWhenInUse:
            let alertController = UIAlertController(title: "位置情報サービス設定",
                                                    message: "このAppの使用中しか許可されていないため、バックグラウンドではログが保存されません。バックグラウンドでも保存するには、位置情報サービスを常に許可に設定してください",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            fallthrough
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        default:
            break
        }
    }
}
