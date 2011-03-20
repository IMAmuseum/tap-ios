#import <Foundation/Foundation.h>

#import "Stop.h"


@interface StopFactory : NSObject {

}

+(id<Stop>)newStopForStopNode:(xmlNodePtr)stop;

@end
