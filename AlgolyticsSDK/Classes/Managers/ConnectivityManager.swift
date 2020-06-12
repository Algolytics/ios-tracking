//
//  ConnectivityManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Reachability
import Network

struct Connectivity: Codable {
    var isConnected: Bool
    var isConnectedToWifi: Bool
    var isConnectedToCellular: Bool
}

public final class ConnectivityManager: BasicManagerType {
    var timer: Timer?
    var data: Connectivity?
    let reachability = try! Reachability()
//    let monitor = NWPathMonitor()

    public init() {
        reachability.whenReachable = { [weak self] reachability in
            if reachability.connection == .wifi {
                print("Reachable via wifi")
                self?.data = Connectivity(isConnected: true, isConnectedToWifi: true, isConnectedToCellular: false)
            } else if reachability.connection == .cellular {
                print("reachable cellular")
                self?.data = Connectivity(isConnected: true, isConnectedToWifi: false, isConnectedToCellular: true)
            } else {
                print("unknown")
                self?.data = Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToCellular: false)
            }
        }
        reachability.whenUnreachable = { [weak self] _ in
            print("Not reachable")
            self?.data = Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToCellular: false)
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

    public func startGettingData() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()
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
