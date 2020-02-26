//
//  TUAlbumPresenter.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

class TUAlbumPresenter {

    private weak var view: TUAlbumViewable?
    private var scrollToBottom = false

    init(view: TUAlbumViewable) {
        self.view = view
    }

    deinit {
        #if DEBUG
        print("解放：\(String(describing: type(of: self)))")
        #endif
    }

}

//MARK: - TUAlbumPresentable

extension TUAlbumPresenter: TUAlbumPresentable {

    func didLoad() {
        self.view?.setupObserver()
        self.view?.setupButton()
        self.view?.setupCollectionView()
    }

    func willAppear() {
        guard !self.scrollToBottom else {
            return
        }
        self.scrollToBottom = true
        self.view?.scrollToBottom()
    }

}
