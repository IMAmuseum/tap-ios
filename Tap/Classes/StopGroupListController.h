//
//  StopGroupListController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapAppDelegate.h"
#import "KeypadController.h"
#import "XPathQuery.h"

@interface StopGroupListController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *stopGroupTable;
    
    NSArray *stopGroups;
}

@property (nonatomic, retain) UITableView *stopGroupTable;
@property (nonatomic, retain) NSArray *stopGroups;

@end
