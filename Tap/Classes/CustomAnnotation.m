//
//  CustomAnnotation.m
//  Tap
//
//  Created by Daniel Cervantes on 3/28/13.
//
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramSubTitle{
    
    self = [super init];
    
    if (self != nil) {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubTitle;
    }
    
    return self;
    
}
@end
