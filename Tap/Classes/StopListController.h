//
//  StopListController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopListController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *stopListTable;
    NSArray *stops;
}

@property (nonatomic, retain) UITableView *stopListTable;
@property (nonatomic, retain) NSArray *stops;

@end
