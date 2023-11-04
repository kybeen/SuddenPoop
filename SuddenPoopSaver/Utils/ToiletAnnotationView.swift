//
//  ToiletAnnotationView.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/11/04.
//

import UIKit
import MapKit

class ToiletAnnotationView: MKMarkerAnnotationView {

    static let identifier = "toiletAnnotationView"
    
    // 어노테이션을 클러스터로 그룹화하려면 clusteringIdentifier 속성을 그룹의 각 어노테이션 뷰에서 동일한 값으로 설정해준다.
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "toilet"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow // 어노테이션 뷰의 종류가 여러개일 때, 서로 다른 어노테이션 뷰 끼리 겹칠 경우 어떤 어노테이션 뷰를 더 우선적으로 보여줄지 정하기 위한 우선순위
        markerTintColor = .gray
        glyphImage = UIImage(systemName: "toilet.circle.fill") // 마커 풍선에 보여줄 이미지
    }
}
