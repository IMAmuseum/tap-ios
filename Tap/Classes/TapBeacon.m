//
//  TapBeacon.m
//  Tap
//
//  Created by Kyle Jaebker on 1/8/15.
//
//

#import "TapBeacon.h"

@implementation TapBeacon

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

-(id)initWithId:(NSString *)bId uuid:(NSUUID *)uuid major:(int)major minor:(int)minor
{
    self = [super init];
    if (self) {
        self.bId = bId;
        self.uuid = uuid;
        self.major = major;
        self.minor = minor;
    }
    
    return self;
}

-(NSString *)proximityToString
{
    NSString *proximityString;
    
    switch(self.beacon.proximity)
    {
        case CLProximityImmediate:
            proximityString = NSLocalizedString(@"Closest", @"Immediate section header title");
            break;
            
        case CLProximityNear:
            proximityString = NSLocalizedString(@"Near", @"Near section header title");
            break;
            
        case CLProximityFar:
            proximityString = NSLocalizedString(@"Far", @"Far section header title");
            break;
            
        default:
            proximityString = NSLocalizedString(@"Unknown", @"Unknown section header title");
            break;
    }
    
    return proximityString;
}

@end
