//
//  StopFactory.h
//  Tap
//
//  Created by Charlie Moad on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
