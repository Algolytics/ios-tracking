//
//  ManagerProtocol.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import Foundation

protocol BasicManagerType {
    init(gettingPoolingTime: Double, sendingPoolingTime: Double)
//    var timer: Timer! { get }
    var gettingPoolingTime: Double { get }
    var sendingPoolingTime: Double { get }
    func startGettingData()
    func stopGettingData()
}

protocol BasicAspectType {
    
}
