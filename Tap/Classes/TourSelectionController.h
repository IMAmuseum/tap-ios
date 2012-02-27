//
//  TourSelectionController.h
//  Tap
//
//  Created by Kyle Jaebker on 6/28/11.
//  Copyright 2011 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapAppDelegate.h"

@interface TourSelectionController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UITableView *tourTable;
    
}

@property (nonatomic, retain) UITableView *tourTable;

@end