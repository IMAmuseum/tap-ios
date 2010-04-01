//
//  StopGroup.h
//  Tap
//
//  Created by Charlie Moad on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseStop.h"
#import "StopFactory.h"


@interface StopGroup : BaseStop {

}

-(NSInteger)numberOfStops;

-(BaseStop*)stopAtIndex:(NSInteger)index;

-(NSString*)getHeaderPortraitImage;

-(NSString*)getHeaderLandscapeImage;

@end
