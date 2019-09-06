//
//  NSFetchedResultsController.swift
//  Film Drawer
//
//  Created by Tudor Croitoru on 08/08/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var shouldReloadCollectionView: Bool = false {
        didSet {
            if shouldReloadCollectionView {
                collectionView.reloadData()
            }
        }
    }
    var blockOperations: [BlockOperation] = []
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        }
        else if type == .update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
        }
        else if type == .move {
            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        }
        else if type == .delete {
            print("Delete Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        if type == .insert {
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.insertSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == .update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.reloadSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == .delete {
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.collectionView!.deleteSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            self.collectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
//            self.shouldReloadCollectionView = true
//        case .delete:
//            collectionView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
//        default:
//            break
//        }
//    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let newIndex = newIndexPath {
////                collectionView.numberOfItems(inSection: 0)
////                collectionView.insertItems(at: [newIndex])
//
//                if collectionView.numberOfItems( inSection: newIndex.section ) == 0 {
////                    self.shouldReloadCollectionView = true
//                    collectionView.reloadData()
//                } else {
//                    collectionView!.insertItems(at: [newIndex])
//                }
//
//
////                if collectionView.numberOfSections > 0 {
////                    print(collectionView.numberOfItems(inSection: newIndex.section))
////                    if collectionView.numberOfItems( inSection: newIndex.section ) == 0 {
////                        self.shouldReloadCollectionView = true
////                    } else {
////                        blockOperations.append(
////                            BlockOperation(block: { [weak self] in
////                                if let self = self {
////                                    DispatchQueue.main.async {
////                                        self.collectionView!.insertItems(at: [newIndex])
////                                    }
////                                }
////                            })
////                        )
////                    }
////
////                } else {
////                    self.shouldReloadCollectionView = true
////                }
//            } else {
//                print("no new index here. NSFetchedResultsCollectionViewController. Line 33.")
//            }
//
//        case .delete:
//            if let index = indexPath {
////                collectionView.deleteItems(at: [index])
//                if collectionView?.numberOfItems( inSection: index.section ) == 1 {
//                    self.shouldReloadCollectionView = true
//                } else {
//                    blockOperations.append(
//                        BlockOperation(block: { [weak self] in
//                            if let self = self {
//                                DispatchQueue.main.async {
//                                    self.collectionView!.deleteItems(at: [index])
//                                }
//                            }
//                        })
//                    )
//                }
//            } else {
//                print("no new index here. NSFetchedResultsCollectionViewController. Line 33.")
//            }
//        case .update:
//            if let index = indexPath {
////                collectionView.reloadItems(at: [index])
//                blockOperations.append(
//                    BlockOperation(block: { [weak self] in
//                        if let self = self {
//                            DispatchQueue.main.async {
//
//                                self.collectionView!.reloadItems(at: [index])
//                            }
//                        }
//                    })
//                )
//            }
//        default:
//            break
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//        if shouldReloadCollectionView {
//            DispatchQueue.main.async {
//                self.collectionView.reloadData();
//            }
//        } else {
//            DispatchQueue.main.async {
//                self.collectionView!.performBatchUpdates({ () -> Void in
//                    for operation: BlockOperation in self.blockOperations {
//                        operation.start()
//                    }
//                }, completion: { (finished) -> Void in
//                    self.blockOperations.removeAll(keepingCapacity: false)
//                })
//            }
//        }
//    }
//
//    deinit {
//        for operation: BlockOperation in blockOperations {
//            operation.cancel()
//        }
//        blockOperations.removeAll(keepingCapacity: false)
//    }
    
}
