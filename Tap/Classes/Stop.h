#import <Foundation/Foundation.h>

#import "TourMLUtils.h"

@protocol Stop <NSObject>

// Initialize the instance with an xml stop
-(id)initWithStopNode:(xmlNodePtr)stop;

// Get the internal stop id
-(NSString*)getStopId;

// Return the stop title
-(NSString*)getTitle;

// Return the stop description or null if not provided
-(NSString*)getDescription;

// Return the path to an icon to use for a stop
-(NSString*)getIconPath;

// Check if this stop provides a view controller
-(BOOL)providesViewController;

// Get a UIViewController for the stop
-(UIViewController*)newViewController;

// Let the stop run itself
-(BOOL)loadStopView;

@end
