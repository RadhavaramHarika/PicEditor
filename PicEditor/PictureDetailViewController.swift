//
//  PictureDetailViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit
protocol PictureDetailViewControllerDelegate: class {
    func deleteInPictureDetailVCPressed()
}

class PictureDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    var selectedImage: UIImage!
    weak var delegate: PictureDetailViewControllerDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectedImage

    }
    
    @IBAction func deletePressed(_ sender: Any) {
        delegate?.deleteInPictureDetailVCPressed()
        navigationController?.popViewController(animated: true)
    }
    

}
