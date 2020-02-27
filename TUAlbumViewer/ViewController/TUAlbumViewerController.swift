//
//  TUAlbumViewerController.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/24.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit
import Photos

public class TUAlbumViewerController: UIViewController {

    @IBOutlet weak var collectionView: TUCollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    private var dataSource = TUAlbumDataSource()
    private var presenter: TUAlbumPresentable?
    private var getImagesHandler: (([UIImage]) -> ())?

    public static func initWithStoryboard(thumbnailSize: CGSize?,
                                          maxSelected: Int?,
                                          getImagesHandler: (([UIImage]) -> ())?) -> TUAlbumViewerController {
        let storyboard = UIStoryboard(name: String(describing: TUAlbumViewerController.self),
                                      bundle: Bundle(for: TUAlbumViewerController.self))
        let vc = storyboard.instantiateInitialViewController() as! TUAlbumViewerController
        vc.setup(thumbnailSize: thumbnailSize, maxSelected: maxSelected, getImagesHandler: getImagesHandler)
        return vc
    }

    public override func viewDidLoad() {
        self.presenter = PresenterBuilder().createTUAlbumPresenter(view: self)
        self.presenter?.didLoad()
    }

    public override func viewWillAppear(_ animated: Bool) {
        self.presenter?.willAppear()
    }

    func setup(thumbnailSize: CGSize?, maxSelected: Int?, getImagesHandler: (([UIImage]) -> ())?) {
        self.getImagesHandler = getImagesHandler

        guard let thumbnailSize = thumbnailSize, let maxSelected = maxSelected else {
            return
        }
        self.dataSource.setup(thumbnailSize: thumbnailSize, maxSelected: maxSelected)
    }

    deinit {
        #if DEBUG
        print("解放：\(String(describing: type(of: self)))")
        #endif

        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    //----- Public Method -----//

    @objc func dismissWithImages() {
        self.dataSource.getImages(indexPaths: self.collectionView.indexPathsForSelectedItems) { [weak self] images in
            self?.dismiss(animated: true, completion: {
                self?.getImagesHandler?(images)
            })
        }
    }

    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: - TUAlbumViewable

extension TUAlbumViewerController: TUAlbumViewable {

    func setupObserver() {
        PHPhotoLibrary.shared().register(self)
    }

    func setupButton() {
        self.doneButton.alpha = 0.0
        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(dismissWithImages), for: .touchUpInside)
    }

    func setupCollectionView() {
        self.view.layoutIfNeeded()
        self.dataSource.delegate = self
        self.collectionView.delegate = self.dataSource
        self.collectionView.dataSource = self.dataSource
        self.collectionView.allowsMultipleSelection = true
        self.dataSource.setupFetchResult(completion: { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.scrollToBottom()
            }
        })
    }

    func scrollToBottom() {
        DispatchQueue.main.async {
            guard self.collectionView.contentSize.height > self.collectionView.frame.height else {
                return
            }
            let offset = CGPoint(x: 0.0, y: self.collectionView.contentSize.height - self.collectionView.frame.height)
            self.collectionView.setContentOffset(offset, animated: false)
        }
    }

}

//MARK: - TUAlbumDataSourceDelegate

extension TUAlbumViewerController: TUAlbumDataSourceDelegate {

    func tapAlbumCell() {
        var alphaValue: CGFloat = 0.0
        if let selectedItems = self.collectionView.indexPathsForSelectedItems {
            alphaValue = selectedItems.isEmpty ? 0.0 : 1.0
        }
        UIView.animate(withDuration: 0.3) {
            self.doneButton.alpha = alphaValue
        }
    }

    func didScroll() {
        self.dataSource.updateCachedAssets(collectionView: self.collectionView)
    }

    func deleteItems(indexPaths: [IndexPath]) {
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPaths)
        })
    }

    func insertItems(indexPaths: [IndexPath]) {
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: indexPaths)
        })
    }

    func reloadItems(indexPaths: [IndexPath]) {
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: indexPaths)
        })
    }

    func moveItem(fromIndex: Int, toIndex: Int) {
        self.collectionView.performBatchUpdates({
            self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
        })
    }

    func reloadData() {
        self.collectionView.reloadData()
    }

    func showDeniedAlert() {
        let alert = UIAlertController(title: "アクセスエラー",
                                      message: "写真へのアクセスが拒否されています。\n設定画面から許可してください。",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: { [weak self] _ in
            self?.close()
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: PHPhotoLibraryChangeObserver

extension TUAlbumViewerController: PHPhotoLibraryChangeObserver {

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.dataSource.photoLibraryDidChange(changeInstance: changeInstance)
        self.collectionView.resetCachedAssets()
    }

}
