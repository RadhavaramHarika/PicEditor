//
//  MainViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var drawingButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var savedPicsButton: UIButton!
    var buttonTitle: String!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        setButtonProperties(filterButton)
        setButtonProperties(drawingButton)
        setButtonProperties(addTextButton)
        setButtonProperties(savedPicsButton)
    }
    
    func setButtonProperties(_ sender: UIButton){
    
        sender.layer.borderWidth = 5
        sender.layer.borderColor = UIColor(red: 212.0/255.0, green: 222.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        sender.layer.cornerRadius = 10
        sender.clipsToBounds = true
    }
    
    @IBAction func buttonPressed(_ sender: UIButton){
        if sender.tag == 0{
            buttonTitle = "Draw"
            openPickImageViewController(title: buttonTitle)
        }
        else if sender.tag == 1{
            buttonTitle = "Filters"
            openPickImageViewController(title: buttonTitle)
        }
        else if sender.tag == 2{
            buttonTitle = "Text"
            openPickImageViewController(title: buttonTitle)
        }
    }
    
    
    @IBAction func openSavedPhotosCollection(_ sender: UIButton) {
        
        let savedAlbumCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "SavedAlbumVC") as! SavedPhotosCollectionViewController
        self.navigationController?.pushViewController(savedAlbumCollectionVC, animated: true)
    }
    
    func openPickImageViewController(title: String){
        
        DispatchQueue.main.async {
            let pickImageVC = self.storyboard?.instantiateViewController(withIdentifier: "PickImageViewController") as! PickImageViewController
            pickImageVC.buttonTitle = title
            self.navigationController?.pushViewController(pickImageVC, animated: true)
        }
        
    }

}
