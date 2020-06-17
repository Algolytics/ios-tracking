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
    var photo: Photo
}

struct Photo: Codable {
    var count: Int
}

public final class PhotoManager: BasicManagerType {
    var timer: Timer?
    var data: PhotoData = PhotoData(photo: Photo(count: 0))

    public init() { }

    @objc private func getData() {
        let result = PHAsset.fetchAssets(with: .image, options: nil)
        print("image count")
        print(result.count)

        data = PhotoData(photo: Photo(count: result.count))

        sendData()
    }

    private func sendData() {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(data)

            let str = String(decoding: jsonData, as: UTF8.self)
            print(str)

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }

        data = PhotoData(photo: Photo(count: 0))
    }

    public func startGettingData() {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 5, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                strongSelf.timer?.fire()
            }
        }
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}
