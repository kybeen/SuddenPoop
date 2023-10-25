//
//  Toilet.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import Foundation

/**
 num: 번호                                         ex) 1
 type: 구분                                         ex) 공중화장실
 name: 화장실명                                 ex) 롯데리아구산점
 streetNameAddr: 소재지도로명주소   ex) 서울특별시 은평구 서오릉로 137 (역촌동)
 streetNumberAddr: 소재지지번주소  ex) 서울특별시 은평구 구산동 17-37 구산동도서관마을
 manBigToiletNum: 남성용-대변기수
 manSmallToiletNum: 남성용-소변기수
 manDisabledBigToiletNum: 남성용-장애인용대변기수
 manDisabledSmallToiletNum: 남성용-장애인용소변기수
 manChildBigToiletNum: 남성용-어린이용대변기수
 manChindSmallToiletNum: 남성용-어린이용소변기수
 womanBigToiletNum: 여성용-대변기수
 womanDisabledBigToiletNum: 여성용-장애인용대변기수
 womanChildBigToiletNum: 여성용-어린이용대변기수
 managementAgencyName: 관리기관명
 callNum: 전화번호
 openTime: 개방시간                     ex) 24시간 | 9:00~18:00
 openDate: 설치연월                     ex) 2002-12
 latitude: WGS84위도
 longitude: WGS84경도
 owner: 화장실소유구분
 locatedPlace: 화장실설치장소유형
 disposalMethod: 오물처리방식
 hasEmergencyBell: 비상벨설치여부
 emergencyBellLocation: 비상벨설치장소
 hasCCTV: 화장실입구CCTV설치유무
 hasDiaperTable: 기저귀교환대유무
 diaperLocation: 기저귀교환대장소
 remodelingDate: 리모델링연월
 date: 데이터기준일자                                      ex) 2020-08-05
 */
struct Toilet: Codable {
    var num: Int?
    var type: String?
    var name: String?
    var streetNameAddr: String?
    var streetNumberAddr: String?
    var manBigToiletNum: Int?
    var manSmallToiletNum: Int?
    var manDisabledBigToiletNum: Int?
    var manDisabledSmallToiletNum: Int?
    var manChildBigToiletNum: Int?
    var manChildSmallToiletNum: Int?
    var womanBigToiletNum: Int?
    var womanDisabledBigToiletNum: Int?
    var womanChildBigToiletNum: Int?
    var managementAgencyName: String?
    var callNum: String?
    var openTime: String?
    var openDate: String? // Date 타입 반환 계산 프로퍼티 있음
    var latitude: Double?
    var longitude: Double?
    var owner: String?
    var locatedPlace: String?
    var disposalMethod: String?
    var hasEmergencyBell: String? // Bool 타입 반환 계산 프로퍼티 있음
    var emergencyBellLocation: String?
    var hasCCTV: String? // Bool 타입 반환 계산 프로퍼티 있음
    var hasDiaperTable: String? // Bool 타입 반환 계산 프로퍼티 있음
    var diaperLocation: String?
    var remodelingDate: String? // Date 타입 반환 계산 프로퍼티 있음
    var date: String? // Date 타입 반환 계산 프로퍼티 있음

    // MARK: - Date 값으로 반환하는 계산 프로퍼티
    var openDateToDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        guard let openDate = openDate else {
            return nil
        }
        if let openDate = dateFormatter.date(from: openDate) {
            return openDate
        } else {
            return nil
        }
    }
    var remodelingDateToDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        guard let remodelingDate = remodelingDate else {
            return nil
        }
        if let remodelingDate = dateFormatter.date(from: remodelingDate) {
            return remodelingDate
        } else {
            return nil
        }
    }
    var dateToDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-DD"
        
        guard let date = date else {
            return nil
        }
        if let date = dateFormatter.date(from: date) {
            return date
        } else {
            return nil
        }
    }

    // MARK: - Bool 값으로 반환하는 계산 프로퍼티
    var hasEmergencyBellToBool: Bool {
        if let hasEmergencyBell = hasEmergencyBell, hasEmergencyBell == "N" {
            return false
        } else {
            return true
        }
    }
    var hasCCTVToBool: Bool {
        if let hasCCTV = hasCCTV, hasCCTV == "N" {
            return false
        } else {
            return true
        }
    }
    var hasDiaperTableToBool: Bool {
        if let hasDiaperTable = hasDiaperTable, hasDiaperTable == "N" {
            return false
        } else {
            return true
        }
    }
}
