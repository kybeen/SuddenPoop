//
//  CustomAnnotation.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/29.
//

import UIKit
import MapKit

final class CustomAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
