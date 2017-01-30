//
//  PictureDetailViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit

class PictureDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectedImage

    }
    
    

}
