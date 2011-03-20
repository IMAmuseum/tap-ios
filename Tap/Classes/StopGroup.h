#import <Foundation/Foundation.h>

#import "BaseStop.h"
#import "StopFactory.h"


@interface StopGroup : BaseStop <Stop> {

}

-(NSInteger)numberOfStops;

-(BaseStop*)stopAtIndex:(NSInteger)index;

-(NSString*)getHeaderPortraitImage;

-(NSString*)getHeaderLandscapeImage;

@end
