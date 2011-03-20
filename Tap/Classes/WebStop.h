#import <Foundation/Foundation.h>

#import "BaseStop.h"


@interface WebStop : BaseStop <Stop> {

}

-(NSString*)getSourcePath;

@end
