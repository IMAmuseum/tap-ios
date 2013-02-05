//
//  StopListController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAPStop;
@interface StopListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *stopListTable;
@property (nonatomic, strong) NSArray *stops;

@end
