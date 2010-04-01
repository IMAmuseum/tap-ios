//
//  VideoStop.h
//  Tap
//
//  Created by Charlie Moad on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BaseStop.h"

@interface VideoStop : BaseStop {
	
	BOOL isAudio;
	
}

@property BOOL isAudio;

-(NSString*)getSourcePath;

@end
