//
//  EmojiViewController.swift
//  mooApp
//
//  Created by tuan on 7/13/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import UIKit

import UIKit
class EmojiView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "cell"
    let ranges = [0x1F601, 0x1F602, 0x1F60D]
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.readJson().count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*let images = self.readJson()
            .map { UnicodeScalar($0) }
            .map { Character($0 as! UnicodeScalar) }
            .map { String($0).image() }*/
        let data : [[String : Any]] = self.readJson()
        collectionView.register(UINib(nibName: "EmojiCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! EmojiViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        var code : String = data[indexPath.item]["code"]! as! String
        code = String(UnicodeScalar(Int(code, radix: 16)!)!)
        cell.icon.image = code.image()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    private func readJson() -> [[String : Any]]{
        var data = [[String : Any]]()
        if let filePath = AppConstants.CONFIG_PATH_FILE_EMOJI {
            do {
                let fileUrl = URL(fileURLWithPath: filePath)
                let jsonData = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                data = try! JSONSerialization.jsonObject(with: jsonData) as! [[String : Any]]
            } catch {
                print(error)
                fatalError("Unable to read contents of the file url")
            }
        }
        return data
    }
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
