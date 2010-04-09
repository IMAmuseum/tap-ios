#import <Foundation/Foundation.h>

#import "ImageStop.h"
#import "PollStop.h"
#import "StopGroup.h"
#import "VideoStop.h"
#import "WebStop.h"


@interface StopFactory : NSObject {

}

+(id)newStopForStopNode:(xmlNodePtr)stop;

@end
