//
//  PhotosManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Photos

struct Photo: Codable {
    var count: Int
}

public final class PhotoManager: BasicManagerType {
    var timer: Timer?
    var data: [Photo] = []

    public init() {
    }

    @objc private func getData() {
        let result = PHAsset.fetchAssets(with: .image, options: nil)
        print("image count")
        print(result.count)

//        let photo = Photo(count: result.count)

//        let encoder = JSONEncoder()
//
//        do {
//            let jsonData = try encoder.encode(bat)
//
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//        print(data.count)
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
