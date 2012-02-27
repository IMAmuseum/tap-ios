#import <Foundation/Foundation.h>

#import "Stop.h"
#import "ImageStop.h"
#import "VideoStop.h"
#import "PollStop.h"
#import "StopGroup.h"


@interface StopFactory : NSObject {

}

+(id<Stop>)newStopForStopNode:(xmlNodePtr)stop;

@end
