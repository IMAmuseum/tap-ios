//
//  CustomAnnotation.h
//  Tap
//
//  Created by Daniel Cervantes on 3/28/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StopAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *stopID;
@property (nonatomic, copy, readonly) NSString *title;

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates
                     title:(NSString *)paramTitle
                    stopID:(NSString *)paramStopID;
@end
