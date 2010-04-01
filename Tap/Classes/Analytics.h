//
//  Analytics.h
//  Tap
//
//  Created by Charlie Moad on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Analytics : NSObject {

}

// Record and event with the analytics system
+ (void)trackAction:(NSString*)action forStop:(NSString*)stop;

@end
