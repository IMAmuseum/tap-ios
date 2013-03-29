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
#import "TAPAsset.h"
#import "TAPContent.h"
#import "JSONKIT.h"
#import "CustomAnnotation.h"

@interface MapViewController ()
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@""];
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
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    // set map center
    NSArray *geoAssets = [appDelegate.currentTour getAppResourcesByUsage:@"geo"];
    if ([geoAssets count]) {
        TAPContent *geoContent = [[[geoAssets objectAtIndex:0] content] anyObject];
        NSDictionary *geoData = [geoContent.data objectFromJSONString];
        NSArray *coordinates = [geoData objectForKey:@"coordinates"];
        
        float zoom = [[appDelegate.currentTour getPropertyValueByName:@"initial_map_zoom"] floatValue];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[coordinates objectAtIndex:1] floatValue], [[coordinates objectAtIndex:0] floatValue]) zoomLevel:zoom animated:YES];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager startUpdatingLocation];
    } else {
        // TODO: Decide what to do if location services is turned off
    }

    [self.view addSubview:self.mapView];
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(39.8273, -86.1892);
    
    /* Create the annotation using the location */
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithCoordinates:location
                                                                           title:@"My Title"
                                                                        subTitle:@"My Sub Title"];
    [self.mapView addAnnotation:annotation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Latitude = %f", newLocation.coordinate.latitude); NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    /* Failed to receive user's location */
}

@end
