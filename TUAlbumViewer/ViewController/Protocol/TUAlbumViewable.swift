//
//  TUAlbumViewable.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

protocol TUAlbumViewable: AnyObject {

    func setupObserver()
    func setupButton()
    func setupCollectionView()
    func scrollToBottom()

}
