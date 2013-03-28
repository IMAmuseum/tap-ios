//
//  StopGroupController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StopGroup;

@interface StopGroupViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (id)initWithStop:(StopGroup *)stop;

@end
