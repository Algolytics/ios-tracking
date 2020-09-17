//
//  PhotosManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Photos

class PhotoData: Event {
    let eventType = "NUMBER_OF_PHOTOS"
    var value: Int = 0
//    let deviceInfo = DeviceManager()
    var time = DateManager.shared.currentDate
}

final class PhotoManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: PhotoData = PhotoData()

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000
    }

    @objc private func getData() {
        let result = PHAsset.fetchAssets(with: .image, options: nil)

        data.time = DateManager.shared.currentDate
        data.value = result.count

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)
    }

    @objc private func sendData() {
//        let encoder = JSONEncoder()
//
//        do {
//            let jsonData = try encoder.encode(data)
//
//            AlgolyticsSDKService.shared.post(data: jsonData)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        data = PhotoData(value: [])
    }

    public func startGettingData() {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.getDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.gettingPoolingTime, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                strongSelf.getDataTimer?.fire()

                strongSelf.sendDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.sendingPoolingTime, target: strongSelf, selector: #selector(strongSelf.sendData), userInfo: nil, repeats: true)
            }
        }
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
