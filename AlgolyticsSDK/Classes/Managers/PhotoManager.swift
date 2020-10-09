//
//  PhotosManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Photos

class PhotoData: Event, Codable {
    let eventType = "NUMBER_OF_PHOTOS"
    var value: Int = 0
    var time = DateManager.shared.currentDate
}

final class PhotoManager: BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: PhotoData = PhotoData()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
    }

    @objc private func getData() {
        let result = PHAsset.fetchAssets(with: .image, options: nil)

        data.time = DateManager.shared.currentDate
        data.value = result.count

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)
    }

    public func startGettingData() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.getDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.gettingPoolingTime, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                    strongSelf.getDataTimer?.fire()
                }
            }
        }
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil
    }
}
