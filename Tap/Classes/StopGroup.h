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
