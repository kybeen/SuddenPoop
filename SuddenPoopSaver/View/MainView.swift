//
//  MainView.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import UIKit
import MapKit

final class MainView: UIView {
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.preferredConfiguration = MKStandardMapConfiguration() // 기본 지도
//        mapView.preferredConfiguration = MKImageryMapConfiguration() // 위성 지도
//        mapView.preferredConfiguration = MKHybridMapConfiguration() // 위성 + 지역 정보
        
        mapView.showsCompass = true // 나침판 표시
//        mapView.showsScale = true // 축척 정보 표시
        
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

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainViewController
    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
    }
}
@available(iOS 13.0.0, *)
struct MainViewPreview: PreviewProvider {
    static var previews: some View {
        MainViewControllerRepresentable()
    }
}
