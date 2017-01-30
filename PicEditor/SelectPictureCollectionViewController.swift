//
//  SelectPictureCollectionViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit

class SelectPictureCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var imageURLs: [String]{
        return (UIApplication.shared.delegate as! AppDelegate).imageURLs
    }
    var photoTitle: String!
    var buttonTitle: String!
    var selectPicture: UIImage!
    let alert = AlertController()
    @IBOutlet weak var SelectCollectionView: UICollectionView!
    
    @IBOutlet weak var SelectCollectionViewLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var MorePicsButtons: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        SelectCollectionView.delegate = self
        SelectCollectionView.dataSource = self
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = false
        setCollectionFlowLayout()
    }
    
    func setCollectionFlowLayout(){
        
        let lineSpace: CGFloat = 2.0
        let cellWidth = (view.frame.size.width )/4
        let cellHeight = cellWidth
        
        SelectCollectionViewLayout.sectionInset = UIEdgeInsets(top:lineSpace, left:lineSpace, bottom: lineSpace, right:lineSpace)
        SelectCollectionViewLayout.minimumLineSpacing = lineSpace
        SelectCollectionViewLayout.minimumInteritemSpacing = lineSpace
        SelectCollectionViewLayout.itemSize = CGSize(width: cellWidth,height: cellHeight)
        SelectCollectionView.reloadData()
        
    }
    
    @IBAction func moresPicturesPressed(_ sender: Any) {
    
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.imageURLs.removeAll()
        
        if Reachability.isConnectedToNetwork(){
            Flickr.shareInstance().getPhotosWithPages(text: photoTitle){(success, error) in
                
                if error == nil{
                    DispatchQueue.main.async {
                        self.SelectCollectionView.reloadData()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        //showalert
                        self.alert.displayAlertView(viewController: self, alertTitle: "Pic Editor", alertMessage: (error?.localizedDescription)!)
                        
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                //ShowAlert
            }
        }
    }
    
    
    func configureCell(_ cell: SelectPictureCollectionViewCell, withImageURL: String){
        
        cell.loadingView.startAnimating()
        cell.loadingView.isHidden = false
        if Reachability.isConnectedToNetwork(){
            Flickr.shareInstance().downloadImageFromImageURL(imagePath: withImageURL){(success, imageData,error) in
                
                if error == nil{
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: imageData!)
                        cell.loadingView.stopAnimating()
                        cell.loadingView.isHidden = true
                    }
                }
                else{
                    DispatchQueue.main.async {
                        cell.loadingView.stopAnimating()
                        cell.loadingView.isHidden = true
                        self.alert.displayAlertView(viewController: self, alertTitle: "Pic Editor", alertMessage: (error?.localizedDescription)!)
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                //ShowAlert
                self.alert.displayAlertView(viewController: self, alertTitle:"No Network", alertMessage: "Make sur your device is connected to network")
            }
        }
    }
    
    func openPicEditorViewController(selectedImage: UIImage, withButtonTitle: String) {
        
        if withButtonTitle == "Filters"{
            
            let editorVC = self.storyboard?.instantiateViewController(withIdentifier: "FiltersEditVC") as! FilterEditViewController
            editorVC.selectedImage = selectedImage
            self.navigationController?.pushViewController(editorVC, animated: true)
        }
        else if withButtonTitle == "Draw"{
            
            let editorVC = self.storyboard?.instantiateViewController(withIdentifier: "DrawEditVC") as! DrawEditViewController
            editorVC.selectedImage = selectedImage
            self.navigationController?.pushViewController(editorVC, animated: true)
            
        }
        else{
            
            let editorVC = self.storyboard?.instantiateViewController(withIdentifier: "TextEditVC") as! TextEditViewController
            editorVC.selectedImage = selectedImage
            self.navigationController?.pushViewController(editorVC, animated: true)
        }
        
    }
    
    //ColecctionView Delegate and datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectCollectionCell", for: indexPath) as! SelectPictureCollectionViewCell
        let imageURL = imageURLs[indexPath.row]
        configureCell(collectionCell, withImageURL: imageURL)
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //open EditorView with buttonTitle and image
        
        let cell = collectionView.cellForItem(at: indexPath) as! SelectPictureCollectionViewCell
        let image = cell.imageView.image
        
        openPicEditorViewController(selectedImage: image!, withButtonTitle: buttonTitle)
    }


}
