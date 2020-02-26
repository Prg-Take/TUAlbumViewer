//
//  TUCollectionView.swift
//  TUAlbumViewer
//
//  Created by Tadasuke Uema on 2020/02/25.
//  Copyright © 2020 Tadasuke Uema. All rights reserved.
//

import UIKit

class TUCollectionView: UICollectionView {

    var prevPreheatRect: CGRect = .zero

    override class func awakeFromNib() {}

    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

}

//MARK: - Public Metohd

extension TUCollectionView {

    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }

    func updateCachedAssets() -> (addedRect: [CGRect], removedRect: [CGRect])? {
        var updateRect: ([CGRect], [CGRect])? = nil
        guard self.superview?.window != nil else {
            return updateRect
        }
        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        let delta = abs(visibleRect.midY - self.prevPreheatRect.midY)
        if delta > self.bounds.height / 3 {
            updateRect = self.differencesBetweenRects(self.prevPreheatRect, preheatRect)
            self.prevPreheatRect = preheatRect
        }
        return updateRect
    }

    func resetCachedAssets() {
        self.prevPreheatRect = .zero
    }

}
