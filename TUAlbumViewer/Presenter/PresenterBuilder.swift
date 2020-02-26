//
//  PresenterBuilder.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import Foundation

class PresenterBuilder {

    init() {}

    func createTUAlbumPresenter(view: TUAlbumViewable) -> TUAlbumPresenter {
        return TUAlbumPresenter(view: view)
    }

}
