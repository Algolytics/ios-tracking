//
//  PhotosManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Photos

struct PhotoData: Codable {
    let eventType = "Photo"
    var value: [Int]
    let deviceInfo = DeviceManager()
}

public final class PhotoManager: BasicManagerType {
    var timer: Timer?
    var sendTimer: Timer?
    var data: PhotoData = PhotoData(value: [])

    public init() { }

    @objc private func getData() {
        let result = PHAsset.fetchAssets(with: .image, options: nil)
        print("image count")
        print(result.count)

        data.value.append(result.count)
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

        data = PhotoData(value: [])
    }

    public func startGettingData() {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 5, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                strongSelf.timer?.fire()

                strongSelf.sendTimer = Timer.scheduledTimer(timeInterval: 5, target: strongSelf, selector: #selector(strongSelf.sendData), userInfo: nil, repeats: true)
            }
        }
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil

        sendTimer?.invalidate()
        sendTimer = nil
    }
}
