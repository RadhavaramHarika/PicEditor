//
//  SavedPhotosCollectionViewController.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit
import CoreData

class SavedPhotosCollectionViewController: UICollectionViewController,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var savedPhotosCollection: UICollectionView!
    @IBOutlet weak var savedPhotosCollectionFlowLayout: UICollectionViewFlowLayout!
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    let alert = AlertController()
    
    var reloadCollectionView: Bool = true
    
    var blockOperations: [BlockOperation] = []
    var selectedIndices = [IndexPath]()
    
    var fetchResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchResultsController?.delegate = self
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedPicture")
            fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true),NSSortDescriptor(key: "imageData", ascending: false)]
            
            // Create the FetchedResultsController
            fetchResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            executeSearch()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        savedPhotosCollection.delegate = self
        savedPhotosCollection.dataSource = self

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedPicture")
        fr.sortDescriptors = [NSSortDescriptor(key: "imageData", ascending: false),
                              NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: "humanReadableDate", cacheName: nil)
        setUpFlowLayout()
        savedPhotosCollection.reloadData()
    }
    
    func getFetchResults(){
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedPicture")
        fr.sortDescriptors = [NSSortDescriptor(key: "imageData", ascending: false),NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        selectedIndices.removeAll()
    }
    
    func setUpFlowLayout(){
        
        let lineSpace: CGFloat = 4.0
        let cellWidth = (view.frame.size.width)/4
        let cellHeight = cellWidth
        print(cellWidth)
        
        savedPhotosCollectionFlowLayout.sectionInset = UIEdgeInsets(top:lineSpace, left:lineSpace, bottom: lineSpace, right:lineSpace)
        savedPhotosCollectionFlowLayout.minimumLineSpacing = lineSpace
        savedPhotosCollectionFlowLayout.minimumInteritemSpacing = lineSpace
        savedPhotosCollectionFlowLayout.itemSize = CGSize(width: cellWidth,height: cellHeight)
        savedPhotosCollection.reloadData()
    }
    
    func executeSearch(){
        
        if let fc = fetchResultsController{
            do{
                try fc.performFetch()
            }
            catch let e as NSError{
                print("Error while performing a search: \n \(e) \n \(fetchResultsController)")
                DispatchQueue.main.async {
                    self.alert.displayAlertView(viewController: self, alertTitle: "Error in executeSearch()", alertMessage: "Error while performing a search: \n \(e) \n \(self.fetchResultsController)")
                }
            }
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchResultsController{
            return (fc.sections?.count)!
        }
        else{
            return 0
        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchResultsController{
            print(fc.sections![section].numberOfObjects)
            return fc.sections![section].numberOfObjects
        }
        else{
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedPhotoCollectionCell", for: indexPath) as! SavedPhotoCollectionViewCell
        let savedPhoto  = fetchResultsController?.object(at: indexPath) as! SavedPicture
        DispatchQueue.main.async {
            cell.imageView.image = UIImage(data: savedPhoto.imageData as! Data)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        let savedPhoto = fetchResultsController?.object(at: indexPath) as! SavedPicture
        
        if let index = selectedIndices.index(of: indexPath){
            selectedIndices.remove(at: index)
        }
        else{
            selectedIndices.append(indexPath)
        }
        let selectedImage = UIImage(data: savedPhoto.imageData as! Data)
        openPictureDetailVC(selectedImage: selectedImage!)
        
    }
    
    func deleteAllImages(){
        for photo in (self.fetchResultsController?.fetchedObjects)!{
            self.stack.context.delete(photo as! SavedPicture)
            self.stack.save()
        }
    }
    
    func deleteSelectedImages(){
       
    if self.selectedIndices.isEmpty{
            self.deleteAllImages()
    }
    else{
        var photos = [SavedPicture]()
        
        let ind = IndexPath()
        for indexPath in selectedIndices{
            photos.append(fetchResultsController?.object(at: indexPath) as! SavedPicture)
        }
        for photo in photos{
            stack.context.delete(photo)
            print("Deleted the coressponding photo")
            stack.save()
        }
        
        getFetchResults()
        savedPhotosCollection.reloadData()
        }
    }
    
    func openPictureDetailVC(selectedImage: UIImage){
        let picturDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "PictureDetailVC") as! PictureDetailViewController
        picturDetailVC.selectedImage = selectedImage
        picturDetailVC.delegate = self
        self.navigationController?.pushViewController(picturDetailVC, animated: true)
    }
    
    //NSFetchedResultsController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reloadCollectionView = false
        blockOperations.removeAll(keepingCapacity: true)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch (type) {
        case .insert:
            self.blockOperations.append(BlockOperation(block: {[weak self] in
                
                if let this = self{
                    this.savedPhotosCollection.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                }
            }))
        case .delete:
            self.blockOperations.append(BlockOperation(block: {[weak self] in
                
                if let this = self{
                    this.savedPhotosCollection.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                }
            }))
        case .update:
            self.blockOperations.append(BlockOperation(block: {[weak self] in
                
                if let this = self{
                    this.savedPhotosCollection.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                }
            }))
        case .move:
            print("This is not required")
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            self.blockOperations.append(BlockOperation(block: {[weak self] in
                
                if let this = self{
                    this.savedPhotosCollection.insertItems(at: [newIndexPath!])
                }
            }))
            
        case .delete:
            self.blockOperations.append(BlockOperation(block: {[weak self] in
                
                if let this = self{
                    this.savedPhotosCollection.deleteItems(at: [indexPath!])
                }
            }))
        case .update:
            self.blockOperations.append(BlockOperation(block: {[weak self] in
                
                if let this = self{
                    this.savedPhotosCollection.reloadItems(at: [indexPath!])
                }
            }))
        case .move:
            print("this is not required")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if reloadCollectionView{
            savedPhotosCollection.reloadData()
        }
        else{
            savedPhotosCollection.performBatchUpdates({() -> Void in
                for operation in self.blockOperations{
                    operation.start()
                }
            }, completion: {(done) in
                self.blockOperations.removeAll(keepingCapacity: false)
            })
        }
    }
}

extension SavedPhotosCollectionViewController: PictureDetailViewControllerDelegate{
    
    func deleteInPictureDetailVCPressed(){
        deleteSelectedImages()
    }
}
