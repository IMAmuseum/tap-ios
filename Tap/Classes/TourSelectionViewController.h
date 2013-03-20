//
//  TourSelectionController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAPTour, TAPStop;

@interface TourSelectionViewController : UITableViewController<NSFetchedResultsControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UISegmentedControl *navigationSegmentControl;
@property (nonatomic, strong) NSArray *stopNavigationControllers;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *tourFetchedResultsController;

- (void)loadTour:(TAPTour *)tour;
- (void)loadStop:(TAPStop *)stopModel;
- (void)indexDidChangeForSegmentedControl:(UISegmentedControl *)segmentedControl;

@end
