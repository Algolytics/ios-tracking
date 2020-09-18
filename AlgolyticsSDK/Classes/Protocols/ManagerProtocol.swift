//
//  ManagerProtocol.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import Foundation

protocol BasicManagerType {
    init(gettingPoolingTime: Double)

    var getDataTimer: Timer? { get }
    var gettingPoolingTime: Double { get }

    func startGettingData()
    func stopGettingData()
}

protocol BasicAspectType {
    
}
