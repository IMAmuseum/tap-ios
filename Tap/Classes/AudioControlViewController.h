//
//  AudioControlViewController.h
//  Tap
//
//  Created by Daniel Cervantes on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioControlViewController : UIViewController <AVAudioPlayerDelegate> {
    AVAudioPlayer *audioPlayer;
    UISlider *audioScrubber;
    UIButton *pausePlayButton;
    UILabel *currentTime;
    UILabel *trackDuration;
    UILabel *trackTitle;
    NSTimer *playbackTimer;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) IBOutlet UISlider *audioScrubber;
@property (nonatomic, retain) IBOutlet UIButton *pausePlayButton;
@property (nonatomic, retain) IBOutlet UILabel *currentTime;
@property (nonatomic, retain) IBOutlet UILabel *trackDuration;
@property (nonatomic, retain) IBOutlet UILabel *trackTitle;
@property (nonatomic, retain) NSTimer *playbackTimer;

@end
