//
//  StopGroupController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAPTour, TAPStop, TAPAsset, TAPAssetRef, TAPConnection, TAPContent, TAPProperty, TAPSource;

@interface StopGroupController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *stopGroupTable;
	IBOutlet UIImageView *bannerImage;
	
	TAPStop *stopGroup;
    NSMutableArray *stops;
    BOOL sectionsEnabled;
}

@property (nonatomic, retain) UITableView *stopGroupTable;
@property (nonatomic, retain) UIImageView *bannerImage;
@property (nonatomic, retain) TAPStop *stopGroup;
@property (nonatomic, retain) NSMutableArray *stops;

- (id)initWithStop:(TAPStop *)stop;

@end
