//
//  ViewController.swift
//  Demo
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit
import TUAlbumViewer

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        let vc = TUAlbumViewerFactory.create(thumbnailSize: CGSize(width: 500.0, height: 500.0),
                                             maxSelected: 4,
                                             getImagesHandler: { images in
                                                print(images)
        })
        self.present(vc, animated: true, completion: nil)
    }

}

