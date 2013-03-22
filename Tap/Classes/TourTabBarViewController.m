//
//  TourNavigationTabBarControllerViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 3/20/13.
//
//

#import "TourTabBarViewController.h"
#import "KeypadViewController.h"
#import "StopListViewController.h"
#import "MapViewController.h"
#import "AppDelegate.h"

@interface TourTabBarViewController ()
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation TourTabBarViewController

- (id)init
{
    self = [super init];
    if(self) {
        KeypadViewController *keypadViewController = [[KeypadViewController alloc] init];
        StopListViewController *stopListViewController = [[StopListViewController alloc] init];
        MapViewController *mapViewController = [[MapViewController alloc] init];
        
        UINavigationController *keypadNavigationController = [[UINavigationController alloc] initWithRootViewController:keypadViewController];
        UINavigationController *stopListNavigationController = [[UINavigationController alloc] initWithRootViewController:stopListViewController];
        UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
        
        NSArray *viewControllers = [[NSArray alloc] initWithObjects:keypadNavigationController, stopListNavigationController, mapNavigationController, nil];
        
        
        self.tabBarController = [[UITabBarController alloc] init];
        [self.tabBarController setDelegate:self];
        [self.tabBarController setViewControllers:viewControllers];
        [self.view addSubview:self.tabBarController.view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
