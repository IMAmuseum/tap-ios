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

@interface StopListController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *stopListTable;
    NSArray *stops;
}

@property (nonatomic, retain) UITableView *stopListTable;
@property (nonatomic, retain) NSArray *stops;

@end
