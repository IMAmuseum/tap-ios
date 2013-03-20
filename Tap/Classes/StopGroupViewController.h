//
//  StopGroupController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StopGroup;

@interface StopGroupViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    BOOL sectionsEnabled;
}

@property (nonatomic, unsafe_unretained) UITableView *stopGroupTable;
@property (nonatomic, unsafe_unretained) UIImageView *bannerImage;
@property (nonatomic, strong) StopGroup *stopGroup;
@property (nonatomic, strong) NSMutableArray *stops;

- (id)initWithStop:(StopGroup *)stop;

@end
