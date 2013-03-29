//
//  MapViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 3/21/13.
//
//

#import "MapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPContent.h"
#import "JSONKIT.h"
#import "StopAnnotation.h"

@interface MapViewController ()
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Navigate the Map"];
        [self.tabBarItem setTitle:NSLocalizedString(@"Map", @"")];
        [self.tabBarItem setImage:[UIImage imageNamed:@"map"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.mapView setDelegate:self];
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];    
    [self.mapView setShowsUserLocation:YES];
    [self.view addSubview:self.mapView];

    // set map center
    NSArray *geoAssets = [appDelegate.currentTour getAppResourcesByUsage:@"geo"];
    if ([geoAssets count]) {
        TAPContent *geoContent = [[[geoAssets objectAtIndex:0] content] anyObject];
        NSDictionary *geoData = [geoContent.data objectFromJSONString];
        NSArray *coordinates = [geoData objectForKey:@"coordinates"];
        
        float zoom = [[appDelegate.currentTour getPropertyValueByName:@"initial_map_zoom"] floatValue];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[coordinates objectAtIndex:1] floatValue], [[coordinates objectAtIndex:0] floatValue]) zoomLevel:zoom animated:YES];
    }
       
    for (TAPStop *stop in [appDelegate.currentTour.stop allObjects]) {
        NSArray *stopGeoAssets = [stop getAssetsByUsage:@"geo"];
        if ([stopGeoAssets count]) {
            TAPContent *stopGeoContent = [[[stopGeoAssets objectAtIndex:0] content] anyObject];
            NSDictionary *stopGeoData = [stopGeoContent.data objectFromJSONString];
            NSArray *stopCoordinates = [stopGeoData objectForKey:@"coordinates"];
            
            StopAnnotation *annotation = [[StopAnnotation alloc] initWithCoordinates:CLLocationCoordinate2DMake([[stopCoordinates objectAtIndex:1] floatValue], [[stopCoordinates objectAtIndex:0] floatValue])
                                                                               title:(NSString *)stop.title
                                                                              stopID:stop.id];
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *AnnotationView = @"AnnotationView";
        
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationView];

        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationView];
        }
        [annotationView setAnnotation:(StopAnnotation *)annotation];
        [annotationView setCanShowCallout:YES];
        [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        [annotationView setPinColor:MKPinAnnotationColorGreen];
        return annotationView;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAPStop *stop = [appDelegate.currentTour stopFromId:[(StopAnnotation *)view.annotation stopID]];
    [self loadStop:stop];
}



@end
