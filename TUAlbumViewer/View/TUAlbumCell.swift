//
//  TUAlbumCell.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit

class TUAlbumCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    var identifier = ""

    override class func awakeFromNib() {}

    override var isSelected: Bool {
        didSet {
            guard oldValue != self.isSelected else {
                return
            }
            self.selectedImageView.isHidden = !self.isSelected
        }
    }

    deinit {
        #if DEBUG
        print("解放：\(String(describing: type(of: self)))")
        #endif
    }

}
