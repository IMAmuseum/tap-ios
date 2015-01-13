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

-(id)initWithId:(NSString *)bId uuid:(NSUUID *)uuid major:(int)major minor:(int)minor name:(NSString *)name
{
    self = [super init];
    if (self) {
        self.name = name;
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
            proximityString = NSLocalizedString(@"immediate", @"Immediate section header title");
            break;
            
        case CLProximityNear:
            proximityString = NSLocalizedString(@"near", @"Near section header title");
            break;
            
        case CLProximityFar:
            proximityString = NSLocalizedString(@"far", @"Far section header title");
            break;
            
        default:
            proximityString = NSLocalizedString(@"unknown", @"Unknown section header title");
            break;
    }
    
    return proximityString;
}

@end
