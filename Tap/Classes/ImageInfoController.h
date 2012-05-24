//
//  ImageInfoController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageInfoController;

@protocol ImageInfoControllerDelegate
- (void)imageInfoControllerDidFinish:(ImageInfoController *)controller;
@end

@interface ImageInfoController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *infoTable;    
    NSString *caption;
    NSString *creditLine;
    int numberOfSections;
}

@property (nonatomic, assign) id <ImageInfoControllerDelegate> delegate;
@property (nonatomic, retain) UITableView *infoTable;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) NSString *creditLine;

- (IBAction)done:(id)sender;

@end
