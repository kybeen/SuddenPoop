//
//  MainViewController.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import UIKit
import MapKit

final class MainViewController: UIViewController {

    private let mainView = MainView()

    var nationWideToilet = [Toilet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadToiletsFromCSV()
        setCenterLocation()

//        self.view.backgroundColor = .brown
        self.view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        mainView.mapView.showsUserLocation = true // 사용자의 현재 위치 표시 활성화
    }

    // MARK: - 지도의 중심 좌표 설정
    private func setCenterLocation() {
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let regionRadius: CLLocationDistance = 1000 // 표시할 지도 영역의 반경 (미터)
        
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )

        mainView.mapView.setRegion(coordinateRegion, animated: true)
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
                        } else if char == "\"" {
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
//        do {
//            let data = try Data(contentsOf: url)
//            let dataEncoded = String(data: data, encoding: .utf8)
//
//            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({ $0.components(separatedBy: ",") }) {
//                for i in 1..<dataArr.count {
//                    nationWideToilet.append(dataArr[i])
//                    if dataArr[i].count > 31 {
//                        print("\(i)번 인덱스 | 길이: \(dataArr[i].count)")
//                    }
//                }
//            }
//        } catch {
//            print("CVS 파일을 읽는 도중 에러가 발생했습니다!!")
//        }
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
