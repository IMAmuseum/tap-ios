//
//  StopListController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAPStop;
@interface StopListController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *stopListTable;
    IBOutlet UIImageView *bannerImage;
    NSArray *stops;
}

@property (nonatomic, retain) UITableView *stopListTable;
@property (nonatomic, retain) NSArray *stops;

@end
