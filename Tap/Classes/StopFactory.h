#import <Foundation/Foundation.h>

#import "Stop.h"
#import "VideoStop.h"


@interface StopFactory : NSObject {

}

+(id<Stop>)newStopForStopNode:(xmlNodePtr)stop;

@end
