//
//  RandomImageListViewModel.swift
//  Picterest
//
//  Created by 김기림 on 2022/07/25.
//

import UIKit

final class ImageListViewModel {
    
    struct CellData {
        var thumbnailURL: String
        var isSaved: Bool
        var id: UUID
        var aspectRatio: CGFloat
        mutating func toggleSavedState() {
            self.isSaved = !self.isSaved
        }
    }
    private let networkManager: NetworkManager
    private var cellDatas: [CellData] = []
    private var currentPage: Int = 1
    var totalCellCount: Int {
        return cellDatas.count
    }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func cellData(_ row: Int) -> CellData? {
        return cellDatas[safe: row]
    }
    
    func updateCellState(completion: @escaping ()->()) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            for i in 0..<self.cellDatas.count {
                guard let cell = self.cellDatas[safe: i] else { return }
                self.cellDatas[i].isSaved = CoreDataManager.shared.isContainImage(imageURL: cell.thumbnailURL)
            }
            completion()
        }
    }
    
    func cellHeightMultiplier(_ row: Int) -> CGFloat {
        guard let data = cellDatas[safe: row] else { return 0.0 }
        return data.aspectRatio
    }
    
    func initData(completion: @escaping (Result<Void,CustomError>)->()) {
        currentPage = 1
        networkManager.getImageInfo(page: currentPage) { [weak self] result in
            switch result {
            case .success(let infos):
                self?.cellDatas = infos.map({ info in
                    let isSaved:Bool = CoreDataManager.shared.isContainImage(imageURL: info.imageURL.thumbnail)
                    let aspactRatio = CGFloat(info.height) / CGFloat(info.width)
                    return CellData(thumbnailURL: info.imageURL.thumbnail, isSaved: isSaved, id: UUID(), aspectRatio: aspactRatio)
                })
                self?.currentPage += 1
                completion(.success(Void()))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func loadExtraData(completion: @escaping (Result<Void,CustomError>)->()) {
        networkManager.getImageInfo(page: currentPage) { [weak self] result in
            switch result {
            case .success(let infos):
                self?.cellDatas += infos.map({ info in
                    let isSaved:Bool = CoreDataManager.shared.isContainImage(imageURL: info.imageURL.thumbnail)
                    let aspactRatio = CGFloat(info.height) / CGFloat(info.width)
                    return CellData(thumbnailURL: info.imageURL.thumbnail, isSaved: isSaved, id: UUID(), aspectRatio: aspactRatio)
                })
                self?.currentPage += 1
                completion(.success(Void()))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func saveImage(row: Int, message: String, completion: @escaping (Result<Void, DBManagerError>) -> ()) {
        guard let cellData = cellDatas[safe: row] else {
            completion(.failure(.failToSaveImageFile))
            return
        }
        let imageURL = cellData.thumbnailURL
        let id = cellData.id
        let aspectRatio = cellData.aspectRatio
        ImageFileManager.shared.saveImageByURL(imageURL: imageURL, id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let location):
                let succeedSaveImageInfo = CoreDataManager.shared.saveImageInfo(id, message, aspectRatio, imageURL, location)
                self.cellDatas[row].toggleSavedState()
                completion(succeedSaveImageInfo ? .success(Void()) : .failure(.failToSaveImageInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

