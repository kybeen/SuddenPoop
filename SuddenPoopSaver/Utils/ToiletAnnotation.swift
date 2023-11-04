//
//  CustomAnnotation.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/29.
//

import UIKit
import MapKit

final class ToiletAnnotation: NSObject, MKAnnotation {

//    static let identifier = "toiletAnnotation"
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
