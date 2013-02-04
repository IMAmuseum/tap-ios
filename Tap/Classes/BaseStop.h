//
//  BaseStop.h
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import <Foundation/Foundation.h>
#import "Stop.h"
#import "TAPStop.h"

@interface BaseStop : NSObject <Stop>

@property (nonatomic, retain) TAPStop *model;

- (id)initWithStopModel:(TAPStop *)stopModel;
// Get the internal stop id
- (NSString *)getStopId;
// Return the stop title
- (NSString *)getTitle;
// Return the stop description or null if not provided
- (NSString *)getDescription;
// Return the path to an icon to use for a stop
- (NSString *)getIconPath;
// Check if this stop provides a view controller
- (BOOL)providesViewController;
// Get a UIViewController for the stop
- (UIViewController *)newViewController;
// Let the stop run itself
- (BOOL)loadStopView;

@end
