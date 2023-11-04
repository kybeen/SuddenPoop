//
//  MainMapView.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import UIKit
import MapKit

final class MainMapView: UIView {
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.preferredConfiguration = MKStandardMapConfiguration() // 기본 지도
//        mapView.preferredConfiguration = MKImageryMapConfiguration() // 위성 지도
//        mapView.preferredConfiguration = MKHybridMapConfiguration() // 위성 + 지역 정보
        
        mapView.showsCompass = true // 나침판 표시
        mapView.showsScale = true // 축척 정보 표시
        
        mapView.showsUserLocation = true // 사용자의 현재 위치 표시 활성화
        mapView.setUserTrackingMode(.follow, animated: true)
        return mapView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setMapView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Preview canvas 세팅
import SwiftUI

struct MainMapViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainMapViewController
    func makeUIViewController(context: Context) -> MainMapViewController {
        return MainMapViewController()
    }
    func updateUIViewController(_ uiViewController: MainMapViewController, context: Context) {
    }
}
@available(iOS 13.0.0, *)
struct MainMapViewPreview: PreviewProvider {
    static var previews: some View {
        MainMapViewControllerRepresentable()
    }
}
