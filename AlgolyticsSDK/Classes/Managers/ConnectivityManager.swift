//
//  ConnectivityManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Reachability
import Network

struct ConnectivityData: Codable {
    let eventType = "Connectivity"
    var connectivityInfo: [Connectivity]
    let deviceInfo = DeviceManager()
}

struct Connectivity: Codable {
    var isConnected: Bool
    var isConnectedToWifi: Bool
    var isConnectedToCellular: Bool
}

public final class ConnectivityManager: BasicManagerType {
    var timer: Timer?
    var sendTimer: Timer?
    var data: ConnectivityData = ConnectivityData(connectivityInfo: [])
    let reachability = try! Reachability()
//    let monitor = NWPathMonitor()

    public init() {
        reachability.whenReachable = { [weak self] reachability in
            if reachability.connection == .wifi {
                print("Reachable via wifi")
                self?.data.connectivityInfo.append(Connectivity(isConnected: true, isConnectedToWifi: true, isConnectedToCellular: false))
            } else if reachability.connection == .cellular {
                print("reachable cellular")
                self?.data.connectivityInfo.append(Connectivity(isConnected: true, isConnectedToWifi: false, isConnectedToCellular: true))
            } else {
                print("unknown")
                self?.data.connectivityInfo.append(Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToCellular: false))
            }
        }
        reachability.whenUnreachable = { [weak self] _ in
            print("Not reachable")
            self?.data.connectivityInfo.append(Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToCellular: false))
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

//        monitor.pathUpdateHandler = { path in
//            if path.usesInterfaceType(.cellular) {
//                print("cellular!!")
//            } else if path.usesInterfaceType(.wifi) {
//                print("wifi!!")
//            }
//
//            print(path.isExpensive)
//        }
//
//        let queue = DispatchQueue.global(qos: .background)
//        monitor.start(queue: queue)
    }

    @objc private func getData() {

    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

            do {
                let jsonData = try encoder.encode(data)

                let str = String(decoding: jsonData, as: UTF8.self)
                print(str)

                AlgolyticsSDKService.shared.post(data: jsonData)

            } catch {
                print(error.localizedDescription)
            }

        data = ConnectivityData(connectivityInfo: [])
    }

    public func startGettingData() {
//        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
//        timer?.fire()
        sendTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}



//For Swift 3, Swift 4 (working with cellular and Wi-Fi):
//
//import SystemConfiguration
//
//public class Reachability {
//
//    class func isConnectedToNetwork() -> Bool {
//
//        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
//        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
//                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
//            }
//        }
//
//        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
//        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
//            return false
//        }
//
//        /* Only Working for WIFI
//        let isReachable = flags == .reachable
//        let needsConnection = flags == .connectionRequired
//
//        return isReachable && !needsConnection
//        */
//
//        // Working for Cellular and WIFI
//        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
//        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
//        let ret = (isReachable && !needsConnection)
//
//        return ret
//
//    }
//}
