//
//  TUAlbumDataSource.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit
import Photos

protocol TUAlbumDataSourceDelegate: AnyObject {

    func tapAlbumCell()
    func didScroll()
    func deleteItems(indexPaths: [IndexPath])
    func insertItems(indexPaths: [IndexPath])
    func reloadItems(indexPaths: [IndexPath])
    func moveItem(fromIndex: Int, toIndex: Int)
    func reloadData()

}

class TUAlbumDataSource: NSObject {

    private let cachingImageManager = PHCachingImageManager()
    private var fetchResult: PHFetchResult<PHAsset>
    private var thumbnailSize = CGSize(width: 500.0, height: 500.0)
    private var maxSelected: Int?
    private let oneSide = CGFloat(roundf(Float(UIScreen.main.bounds.width / 3))) - 1.0
    weak var delegate: TUAlbumDataSourceDelegate?

    override init() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        self.fetchResult = PHAsset.fetchAssets(with: options)
    }

    deinit {
        #if DEBUG
        print("解放：\(String(describing: type(of: self)))")
        #endif
    }

    //----- Public Method -----//

    func setup(thumbnailSize: CGSize, maxSelected: Int?) {
        self.thumbnailSize = thumbnailSize
        self.maxSelected = maxSelected
    }

    func updateCachedAssets(collectionView: TUCollectionView) {
        guard let updateRects = collectionView.updateCachedAssets() else {
            return
        }
        let addedAssets = updateRects.addedRect.flatMap { rect in
            collectionView.indexPathsForElements(in: rect)
        }.map { indexPath in
            self.fetchResult.object(at: indexPath.item)
        }
        let removedAssets = updateRects.removedRect.flatMap { rect in
            collectionView.indexPathsForElements(in: rect)
        }.map { indexPath in
            self.fetchResult.object(at: indexPath.item)
        }
        self.cachingImageManager.startCachingImages(for: addedAssets, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        self.cachingImageManager.stopCachingImages(for: removedAssets, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
    }

    func photoLibraryDidChange(changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: self.fetchResult) else {
            return
        }
        DispatchQueue.main.sync {
            self.fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                if let removed = changes.removedIndexes, removed.count > 0 {
                    self.delegate?.deleteItems(indexPaths: removed.map({ IndexPath(item: $0, section: 0) }))
                }
                if let inserted = changes.insertedIndexes, inserted.count > 0 {
                    self.delegate?.insertItems(indexPaths: inserted.map({ IndexPath(item: $0, section: 0) }))
                }
                if let changed = changes.changedIndexes, changed.count > 0 {
                    self.delegate?.reloadItems(indexPaths: changed.map({ IndexPath(item: $0, section: 0) }))
                }
                changes.enumerateMoves { fromIndex, toIndex in
                    self.delegate?.moveItem(fromIndex: fromIndex, toIndex: toIndex)
                }
            } else {
                self.delegate?.reloadData()
            }
            self.cachingImageManager.stopCachingImagesForAllAssets()
        }
    }

    func getImages(indexPaths: [IndexPath]?, completion: @escaping (([UIImage]) -> ())) {
        var images = [UIImage]()
        guard let indexPaths = indexPaths, !indexPaths.isEmpty else {
            completion(images)
            return
        }
        var completionCount = 0
        for indexPath in indexPaths {
            let asset = self.fetchResult.object(at: indexPath.row)
            self.cachingImageManager.requestImage(for: asset,
                                                  targetSize: UIScreen.main.bounds.size,
                                                  contentMode: .aspectFill,
                                                  options: nil,
                                                  resultHandler: { image, _ in
                                                    if let image = image {
                                                        images.append(image)
                                                    }
                                                    completionCount += 1
                                                    if completionCount == indexPaths.count {
                                                        completion(images)
                                                    }
            })
        }
    }

}

//MARK: - UICollectionViewDataSource

extension TUAlbumDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: TUAlbumCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TUAlbumCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.identifier = asset.localIdentifier
        self.cachingImageManager.requestImage(for: asset,
                                              targetSize: self.thumbnailSize,
                                              contentMode: .aspectFill,
                                              options: nil,
                                              resultHandler: { image, _ in
                                                DispatchQueue.main.async {
                                                    if cell.identifier == asset.localIdentifier {
                                                        cell.imageView.image = image
                                                    }
                                                }
        })
        return cell
    }

}

//MARK: - UICollectionViewDelegate

extension TUAlbumDataSource: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.tapAlbumCell()

        guard
            let maxSelected = self.maxSelected,
            let selectedItems = collectionView.indexPathsForSelectedItems,
            maxSelected < selectedItems.count else {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.delegate?.tapAlbumCell()
    }

}

//MARK: - UICollectionViewLayout

extension TUAlbumDataSource: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.oneSide, height: self.oneSide)
    }

}

// MARK: UIScrollViewDelegate

extension TUAlbumDataSource: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.didScroll()
    }

}
