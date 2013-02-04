//
//  StopFactory.h
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import <Foundation/Foundation.h>

#import "BaseStop.h"
#import "TAPStop.h"

@interface StopFactory : NSObject

+ (BaseStop *)newStopForStopNode:(TAPStop *)stopModel;

@end
