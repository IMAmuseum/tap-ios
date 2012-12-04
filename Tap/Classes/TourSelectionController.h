//
//  TourSelectionController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 IMA Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TourSelectionController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *tourFetchedResultsController;

@end
