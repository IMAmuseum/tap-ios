//
//  CustomAnnotation.m
//  Tap
//
//  Created by Daniel Cervantes on 3/28/13.
//
//

#import "StopAnnotation.h"

@implementation StopAnnotation

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates
                     title:(NSString *)paramTitle
                    stopID:(NSString *)paramStopID
{
    
    self = [super init];
    
    if (self != nil) {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _stopID = paramStopID;
    }
    
    return self;
}
@end
