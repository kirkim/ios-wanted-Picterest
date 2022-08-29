//
//  SavedImageListViewModel.swift
//  Picterest
//
//  Created by 김기림 on 2022/07/28.
//

import UIKit

final class SavedImageListViewModel {
    
    private var cellDatas: [ImageCoreInfo] = []
    var totalCellCount: Int {
        return cellDatas.count
    }
    
    func cellData(_ row: Int) -> ImageCoreInfo? {
        return cellDatas[safe: row]
    }

    func updateData(completion: @escaping () -> ()) {
        self.cellDatas = CoreDataManager.shared.readImageInfos()
        completion()
    }
    
    func cellSize(_ row: Int) -> CGSize {
        let aspectRatio = cellDatas[row].aspectRatio
        let width = CellStyle.Math.cellWidth
        let height = width*aspectRatio
        return CGSize(width: width, height: height)
    }
    
    func removeCell(at id: UUID, completion: @escaping () -> ()) {
        DispatchQueue.global().async { [weak self] in
            do {
                let fileLocation = try CoreDataManager.shared.removeImageInfo(at: id)
                try ImageFileManager.shared.removeImage(at: fileLocation)
                self?.updateData(completion: completion)
            } catch {
                if let error = error as? DBManagerError {
                    if (error == .failToRemoveImageFile) {
                        self?.updateData(completion: completion)
                    }
                    print(error.description)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
