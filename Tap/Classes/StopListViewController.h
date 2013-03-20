//
//  StopListController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, unsafe_unretained) IBOutlet UITableView *stopListTable;
@property (nonatomic, strong) NSArray *stops;

@end
