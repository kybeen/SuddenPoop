//
//  MainMapViewController.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import CoreLocation
import UIKit
import MapKit

import SnapKit

final class MainMapViewController: UIViewController {

    // 앱에서 위치 관련 이벤트를 다룰 때 사용하는 객체
    var locationManager: CLLocationManager!
    let regionMeter: CLLocationDistance = 3000 // 표시할 지도의 영역 반경(미터)

    private let mainMapView = MainMapView()
    var nationWideToilet = [Toilet]() // 화장실 데이터
    var annotations = [MKAnnotation]() // 화장실 어노테이션

    override func viewDidLoad() {
        super.viewDidLoad()
        // CoreLocation & MapKit 관련 세팅
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mainMapView.mapView.delegate = self
//        mainMapView.mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: ToiletAnnotation.identifier)
        mainMapView.mapView.register(ToiletAnnotationView.self, forAnnotationViewWithReuseIdentifier: ToiletAnnotationView.identifier) // 클러스터링 하려면 커스텀 어노테이션 뷰를 사용해야 함
        mainMapView.mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: ClusterAnnotationView.identifier)

        // 화장실 데이터 불러오고 지도에 표시
        loadToiletsFromCSV()
        setToiletAnnotation(toilets: nationWideToilet)

        self.view.addSubview(mainMapView)
        mainMapView.translatesAutoresizingMaskIntoConstraints = false
        mainMapView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    // MARK: - 위치 권한 확인
    func checkUserDeviceLoactionServiceAuthorization() {
        // 디바이스 자체에 위치 서비스가 활성화 상태인지 확인
        guard CLLocationManager.locationServicesEnabled() else {
            // 시스템 설정으로 유도하는 커스텀 알럿
            showRequestLocationServiceSettingAlert()
            return
        }
        
        // 앱에 대한 권한 상태 확인
        let authorizationStatus: CLAuthorizationStatus
        // 앱의 권한 상태 가져오기
        authorizationStatus = locationManager.authorizationStatus
//        if #available(iOS 14.0, *) {
//            authorizationStatus = locationManager.authorizationStatus
//        } else {
//            authorizationStatus = CLLocationManager.authorizationStatus()
//        }

        // 권한 상태값에 따라 분기처리를 수행하는 메서드 실행
        checkUserCurrentLocationAuthorization(status: authorizationStatus)
    }
    
    // MARK: - 앱에 대한 위치 권한이 부여된 상태인지 확인하는 메서드
    /**
     CLAuthorizationStatus(권한 상태에 대한 enum)
     - ✅ .notDetermined : 사용자가 권한에 대한 설정을 선택하지 않은 상태
     - ✅ .restricted : 위치 서비스에 대한 권한이 없는 상태 / 자녀 보호 기능 등의 요인으로 디바이스 자체에 활성이 제한되어 있는 상태
     - ✅ .denied
        - 사용자가 앱에 대한 권한을 거부한 상태
        - 권한을 승인했지만 추후에 시스템 설정에서 비활성화한 경우
        - 사용자가 디바이스 전체에 대해 위치 서비스를 비활성화한 경우
        - 비행기 모드 등의 상황으로, 위치 서비스를 이용할 수 없는 상황
     - ✅ .authorizedAlways : 앱이 백그라운드 상태에서도 위치 서비스를 이용할 수 있도록 승인된 상태
     - ✅ .authorizedWhenInUse : 앱이 포어그라운드 상태에서만 위치 서비스를 이용할 수 있도록 승인된 상태 (앱을 사용 중일 때만)
     */
    func checkUserCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // 권한 요청을 보내기 전에 desiredAccuracy 설정이 필요함 - 정확할수록 배터리 소모 UP
            // TODO: 추후 유저가 설정 가능하도록 하기
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 가능한 최고 수준의 정확도로 사용
            // 권한 요청을 보낸다.
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // 시스템 설정에서 설정값을 변경하도록 유도한다.
            showRequestLocationServiceSettingAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            // manager 인스턴스를 사용하여 사용자의 위치를 가져온다.
            locationManager.startUpdatingLocation()
        default:
            print("Default")
        }
    }
    
    // MARK: - 디바이스의 시스템 설정으로 유도하는 커스텀 알럿
    func showRequestLocationServiceSettingAlert() {
        let requestLocationServiceSettingAlert = UIAlertController(
            title: "위치 정보 이용 설정 필요",
            message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 👉 개인정보 보호'에서 위치 서비스를 활성화해주세요.",
            preferredStyle: .alert
        )
        let goToSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        requestLocationServiceSettingAlert.addAction(cancel)
        requestLocationServiceSettingAlert.addAction(goToSetting)
        present(requestLocationServiceSettingAlert, animated: true)
    }

    // MARK: - 지도의 중심 좌표 설정
    private func setCenterLocation(center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: regionMeter,
            longitudinalMeters: regionMeter
        )
        mainMapView.mapView.setRegion(region, animated: true)
    }

    // 지도 Annotation 생성 메서드
    func setToiletAnnotation(toilets: [Toilet]) {
        for toilet in toilets {
            let annotataion = ToiletAnnotation(
                title: toilet.name ?? "이름 불러오지 못함",
                subtitle: toilet.streetNameAddr ?? "주소 불러오지 못함",
                coordinate: CLLocationCoordinate2D(
                    latitude: toilet.latitude ?? 0,
                    longitude: toilet.longitude ?? 0
                )
            )
            annotataion.imageName = "toilet.circle.fill"
            
            annotations.append(annotataion)
        }
        mainMapView.mapView.addAnnotations(annotations)
    }
}

// MARK: - 화장실 데이터 불러오기 관련 메서드
extension MainMapViewController {

    // MARK: - 화장실 데이터 불러오기
    private func loadToiletsFromCSV() {
        print("loadToiletsFromCSV()...")
        let path = Bundle.main.path(forResource: "NationWideToilet", ofType: "csv")!
        print(path)

        parseCSV(url: URL(fileURLWithPath: path))
    }
    
    // MARK: - CSV 파일을 파싱하는 메서드
    private func parseCSV(url: URL) {
        print("parseCSV()...")
        do {
            let data = try Data(contentsOf: url)
            if let dataEncoded = String(data: data, encoding: .utf8) {
                let lines = dataEncoded.components(separatedBy: "\n")
                
                for line in lines {
                    var fields: [String] = []
                    var insideField = ""
                    var insideFieldActive = false
                    
                    for char in line {
                        if char == "," && !insideFieldActive {
                            fields.append(insideField)
                            insideField = ""
                        } else if char == "\"" { // ""로 둘러싸인 값을 감지하고, 그 안에 있는 ,는 구분자로 인식하지 않도록 하기 위한 처리
                            insideFieldActive.toggle()
                        } else {
                            insideField.append(char)
                        }
                    }
                    fields.append(insideField)
                    
                    if fields.count > 31 {
                        print("길이: \(fields.count)")
                    }
                    // nationWideToilet 배열에 Toilet 인스턴스들을 추가해준다.
                    nationWideToilet.append(convertToToilet(toiletArr: fields))
                }
            }
        } catch {
            print("CSV 파일을 읽는 도중 에러가 발생했습니다!!")
        }
    }

    // MARK: - Toilet 인스턴스로 변환
    private func convertToToilet(toiletArr: [String]) -> Toilet {
        let toilet = Toilet(
            num: Int(toiletArr[0]),
            type: toiletArr[1],
            name: toiletArr[2],
            streetNameAddr: toiletArr[3],
            streetNumberAddr: toiletArr[4],
            manBigToiletNum: Int(toiletArr[5]),
            manSmallToiletNum: Int(toiletArr[6]),
            manDisabledBigToiletNum: Int(toiletArr[7]),
            manDisabledSmallToiletNum: Int(toiletArr[8]),
            manChildBigToiletNum: Int(toiletArr[9]),
            manChildSmallToiletNum: Int(toiletArr[10]),
            womanBigToiletNum: Int(toiletArr[11]),
            womanDisabledBigToiletNum: Int(toiletArr[12]),
            womanChildBigToiletNum: Int(toiletArr[13]),
            managementAgencyName: toiletArr[14],
            callNum: toiletArr[15],
            openTime: toiletArr[16],
            openDate: toiletArr[17],
            latitude: Double(toiletArr[18]),
            longitude: Double(toiletArr[19]),
            owner: toiletArr[20],
            locatedPlace: toiletArr[21],
            disposalMethod: toiletArr[22],
            hasEmergencyBell: toiletArr[23],
            emergencyBellLocation: toiletArr[24],
            hasCCTV: toiletArr[25],
            hasDiaperTable: toiletArr[26],
            diaperLocation: toiletArr[27],
            remodelingDate: toiletArr[28],
            date: toiletArr[29]
        )
        return toilet
    }
}

// MARK: - CLLocationManagerDelegate 델리게이트 구현
extension MainMapViewController: CLLocationManagerDelegate {

    // 사용자의 위치를 성공적으로 가져왔을 때 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 정보를 배열로 입력받는다. → 마지막 index 값이 가장 정확
        if let coordinate = locations.last?.coordinate {
            // 사용자 위치 정보를 지도의 중심으로 위치시켜준다.
            setCenterLocation(center: coordinate)
        }
        
        // startUpdatingLocation()을 사용하여 사용자 위치를 가져왔을 때 불필요한 업데이트를 방지하기 위해 호출
        // TODO: - 이 자리에 둬도 되나? 확인 필요함
        locationManager.stopUpdatingLocation()
    }
    
    // 사용자가 GPS 사용이 불가한 지역에 있는 등 위치 정보를 가져오지 못했을 때 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
    
    // 앱에 대한 권한 설정이 변경되면 호출 (iOS 14 이상)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 사용자 디바이스의 위치 서비스가 활성화 상태인지 확인하는 메서드 호출
        checkUserDeviceLoactionServiceAuthorization()
    }
//    // 앱에 대한 권한 설정이 변경되면 호출 (iOS 14 미만)
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        // 사용자 디바이스의 위치 서비스가 활성화 상태인지 확인하는 메서드 호출
//        checkUserDeviceLoactionServiceAuthorization()
//    }
}

// MARK: MKMapViewDelegate 델리게이트 구현
extension MainMapViewController: MKMapViewDelegate {
    
    // 지도를 스크롤 및 확대할 때 호출되는 메서드 👉 지도 영역이 변경될 때
    // ex) 특정 영역을 확대했을 때, 해당 지역의 정보를 갖고올 떄 등...
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("지도 위치 변경!!")
    }
    
    // 사용자 위치가 업데이트 될 때 호출되는 메서드
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("사용자 위치 업데이트!!")
    }
    
    // AnnotationView를 커스터마이징
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 현재 유저의 위치를 표시해주는 동그라미도 어노테이션에 해당하기 때문에 이 처리가 돼있지 않으면 유저 위치 어노테이션이 보이지 않는다.
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
//        
//        var annotationView: MKAnnotationView?
//        
//        if let annotation = annotation as? ToiletAnnotation {
//            annotationView = setToiletAnnotationView(for: annotation, on: mapView)
//        }
//        
//        return annotationView
        
        switch annotation {
        case is MKClusterAnnotation:
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: ClusterAnnotationView.identifier)
        default:
            return ToiletAnnotationView(annotation: annotation, reuseIdentifier: ToiletAnnotationView.identifier)
        }
//        guard let annotation = annotation as? ToiletAnnotation else {
//            return nil
//        }
//        return ToiletAnnotationView(annotation: annotation, reuseIdentifier: ToiletAnnotationView.identifier)
    }

//    // 재사용 식별자를 사용해서 AnnotationView 생성
//    private func setToiletAnnotationView(for annotation: ToiletAnnotation, on mapView: MKMapView) -> MKAnnotationView {
//        let reuseIdentifier = ToiletAnnotation.identifier
//        let toiletAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
//        
//        toiletAnnotationView.canShowCallout = true
//        
//        // Provide the annotation view's image.
//        let image = UIImage(systemName: "toilet.circle.fill")!
//        toiletAnnotationView.image = image
//        
//        // Provide the left image icon for the annotation.
//        toiletAnnotationView.leftCalloutAccessoryView = UIImageView(image: UIImage(systemName: "star"))
//        
//        let button = UIButton(type: .detailDisclosure)
//        toiletAnnotationView.rightCalloutAccessoryView = button
//        
//        // Offset the flag annotation so that the flag pole rests on the map coordinate.
//        let offset = CGPoint(x: image.size.width / 2, y: -(image.size.height / 2))
//        toiletAnnotationView.centerOffset = offset
//        
//        return toiletAnnotationView
//    }
    
    // MKAnnotationView에서 콜아웃 버튼을 탭할 때 호출
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // ex. 버튼 클릭 시 다른 뷰컨트롤러로 이동, 작업 수행
    }
}
