//
//  MKMapView+MKMapView_ZoomLevel.h
//  Tap
//
//  Created by Daniel Cervantes on 3/21/13.
//
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end
