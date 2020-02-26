//
//  TUAlbumViewerFactory.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/24.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit

public class TUAlbumViewerFactory: NSObject {

    public static func create(thumbnailSize: CGSize?,
                              maxSelected: Int?,
                              getImagesHandler: (([UIImage]) -> ())?) -> TUAlbumViewController {
        let storyboard = UIStoryboard(name: "TUAlbumViewController", bundle: Bundle(for: TUAlbumViewController.self))
        let vc = storyboard.instantiateInitialViewController() as! TUAlbumViewController
        vc.setup(thumbnailSize: thumbnailSize, maxSelected: maxSelected, getImagesHandler: getImagesHandler)
        return vc
    }

    deinit {
        print("解放：\(String(describing: type(of: self)))")
    }

}
