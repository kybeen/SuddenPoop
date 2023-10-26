//
//  MainView.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import UIKit
import MapKit

final class MainView: UIView {

//    let testLabel: UILabel = {
//        let testLabel = UILabel()
//        testLabel.text = "테스트"
//        return testLabel
//    }()
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
//        setTestLabel()
        setMapView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

//    private func setTestLabel() {
//        testLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(testLabel)
//        NSLayoutConstraint.activate([
//            testLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            testLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            testLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            testLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
//        ])
//    }
    private func setMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: self.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
