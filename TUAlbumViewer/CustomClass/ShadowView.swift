//
//  ShadowView.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/26.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override func awakeFromNib() {
        self.backgroundColor = .clear

        guard let gradientLayer = self.layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor,
                                UIColor.black.withAlphaComponent(0.4).cgColor,
                                UIColor.black.withAlphaComponent(0.0).cgColor]
        gradientLayer.locations = [0.2, 0.5]
    }

    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

}
