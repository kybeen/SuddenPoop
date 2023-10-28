//
//  MainViewController.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import CoreLocation
import UIKit
import MapKit

import SnapKit

final class MainViewController: UIViewController {

    // 앱에서 위치 관련 이벤트를 다룰 때 사용하는 객체
    var locationManager: CLLocationManager!

    private let mainView = MainView()
    var nationWideToilet = [Toilet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mainView.mapView.delegate = self

        loadToiletsFromCSV()
        setAnnotation(toilets: nationWideToilet)

        self.view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        mainView.mapView.showsUserLocation = true // 사용자의 현재 위치 표시 활성화
        mainView.mapView.setUserTrackingMode(.follow, animated: true)
    }

    // MARK: - 위치 권한 확인
    func checkUserDeviceLoactionServiceAuthorization() {
        // 디바이즈 자체에 위치 서비스가 활성화 상태인지 확인
        guard CLLocationManager.locationServicesEnabled() else {
            // 시스템 설정으로 유도하는 커스텀 알럿
            showRequestLocationServiceSettingAlert()
            return
        }
        
        // 앱에 대한 권한 상태 확인
        let authorizationStatus: CLAuthorizationStatus
        // 앱의 권한 상태 가져오기
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        // 권한 상태값에 따라 분기처리를 수행하는 메서드 실행
        checkUserCurrentLocationAuthorization(authorizationStatus)
    }
    
    // MARK: - 앱에 대한 위치 권한이 부여된 상태인지 확인하는 메서드
    func checkUserCurrentLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // 사용자가 권한에 대한 설정을 선택하지 않은 상태
            
            // 권한 요청을 보내기 전에 desiredAccuracy 설정 필요
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // 권한 요청을 보낸다.
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // 사용자가 명시적으로 권한을 거부했거나, 위치 서비스 활성화가 제한된 상태
            // 시스템 설정에서 설정값을 변경하도록 유도한다.
            // 시스템 설정으로 유도하는 커스텀 알럿
            showRequestLocationServiceSettingAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            // 앱을 사용중일 때 혹은 항상 위치 서비스를 이용할 수 있는 상태
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
        let regionMeter: CLLocationDistance = 1000 // 표시할 지도의 영역 반경(미터)
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: regionMeter,
            longitudinalMeters: regionMeter
        )
        mainView.mapView.setRegion(region, animated: true)
    }

    // 지도 Annotation 생성 메서드
    func setAnnotation(toilets: [Toilet]) {
        var annotations = [MKAnnotation]()
        for toilet in toilets {
            let annotataion = CustomAnnotation(
                title: toilet.name ?? "이름 불러오지 못함",
                subtitle: toilet.streetNameAddr ?? "주소 불러오지 못함",
                coordinate: CLLocationCoordinate2D(
                    latitude: toilet.latitude ?? 0,
                    longitude: toilet.longitude ?? 0
                )
            )
            annotations.append(annotataion)
        }
        mainView.mapView.addAnnotations(annotations)
        
        
//        let annotataion = MKPointAnnotation()
        
//        if let center = center {
//            annotataion.coordinate = center
//        } else {
//            annotataion.coordinate = CLLocationCoordinate2D(latitude: 36.017512842322766, longitude: 129.321726908621)
//        }
//        annotataion.title = "이름"
//        annotataion.subtitle = "서브타이틀"
        
//        mainView.mapView.addAnnotation(annotataion)
    }
}

// MARK: - 화장실 데이터 관련 메서드
extension MainViewController {
    
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
                    nationWideToilet.append(convertToToilet(toiletArr: fields))
                }
            }
        } catch {
            print("CSV 파일을 읽는 도중 에러가 발생했습니다!!")
        }
    }

    // MARK: - 화장실 불러오기
    private func loadToiletsFromCSV() {
        print("loadToiletsFromCSV()...")
        let path = Bundle.main.path(forResource: "NationWideToilet", ofType: "csv")!
        print(path)

        parseCSV(url: URL(fileURLWithPath: path))
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
extension MainViewController: CLLocationManagerDelegate {

    // 사용자의 위치를 성공적으로 가져왔을 때 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 정보를 배열로 입력받는다. → 마지막 index 값이 가장 정확
        if let coordinate = locations.last?.coordinate {
            // 사용자 위치 정보 사용
            setCenterLocation(center: coordinate)
            print("사용자 위치: \(coordinate)")
        }
        
        // startUpdatingLocation()을 사용하여 사용자 위치를 가져왔을 때 불필요한 업데이트를 방지하기 위해 호출
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
    
    // 앱에 대한 권한 설정이 변경되면 호출 (iOS 14 미만)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 사용자 디바이스의 위치 서비스가 활성화 상태인지 확인하는 메서드 호출
        checkUserDeviceLoactionServiceAuthorization()
    }
}

// MARK: MKMapViewDelegate 델리게이트 구현
extension MainViewController: MKMapViewDelegate {

    // AnnotationView를 커스터마이징
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
        annotationView.canShowCallout = true // 어노테이션 클릭 시 콜아웃(팝업) 표시
        return annotationView
    }
    
    // MKAnnotationView에서 콜아웃 버튼을 탭할 때 호출
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // ex. 버튼 클릭 시 다른 뷰컨트롤러로 이동, 작업 수행
    }
}
