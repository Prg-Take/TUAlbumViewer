//
//  TUAlbumPresentable.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import Foundation

protocol TUAlbumPresentable: AnyObject {

    func didLoad()
    func willAppear()

}
