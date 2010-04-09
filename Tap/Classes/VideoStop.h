#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BaseStop.h"

@interface VideoStop : BaseStop {
	
	BOOL isAudio;
	
}

@property BOOL isAudio;

-(NSString*)getSourcePath;

@end
