//
//  AudioStopController.h
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class AudioStop;

@interface AudioStopViewController : MPMoviePlayerViewController

@property (nonatomic, strong) AudioStop *audioStop;

- (id)initWithStop:(AudioStop *)stop;

@end
