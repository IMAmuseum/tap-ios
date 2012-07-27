//
//  AudioControlViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioControlViewController.h"
#import "TAPAsset.h"
#import "TAPSource.h"

#define PAUSE_ICON @"icon-pause-btn.png"
#define PLAY_ICON @"icon-play-btn.png"

@interface AudioControlViewController (Private)
- (IBAction)togglePlay;
- (IBAction)moveScurbber:sender;
- (void)updateTime;
@end

@implementation AudioControlViewController

@synthesize audio = _audio;
@synthesize audioPlayer = _audioPlayer;
@synthesize audioScrubber = _audioScrubber;
@synthesize pausePlayButton = _pausePlayButton;
@synthesize currentTime = _currentTime;
@synthesize trackDuration = _trackDuration;
@synthesize trackTitle = _trackTitle;
@synthesize playbackTimer = _playbackTimer;

- (id)initWithAudio:(TAPAsset *)asset forViewController:(UIViewController *)controller
{
    if ((self = [super initWithNibName:@"AudioControlViewController" bundle:[NSBundle mainBundle]])) {
        [self setAudio:asset];
        
        UIButton *musicControlView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 16, 16)];
        [musicControlView addTarget:self action:@selector(toggleAudioControl:) forControlEvents:UIControlEventTouchUpInside];
        [musicControlView setBackgroundImage: [UIImage imageNamed:@"icon-audio-btn.png"] forState: UIControlStateNormal];
        UIBarButtonItem *audioControlToggle = [[UIBarButtonItem alloc] initWithCustomView:musicControlView];
        [[controller navigationItem] setRightBarButtonItem:audioControlToggle];
        [musicControlView release];
        [audioControlToggle release];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
    
    [_audioScrubber setThumbImage:[UIImage imageNamed:@"slider-button.png"] forState:UIControlStateNormal];
    
    NSURL *audioUrl = [NSURL fileURLWithPath:[[[_audio source] anyObject] uri]];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
    if (error) {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        [_audioPlayer setDelegate:self];
        [_audioPlayer prepareToPlay];
        [_audioScrubber setMaximumValue:(int)[_audioPlayer duration] - 1];
        [_audioScrubber setMinimumValue:0.0f];
        [_audioScrubber setValue:0.0f];
        float minutes = floor(_audioPlayer.duration / 60);
        float seconds = _audioPlayer.duration - (minutes * 60);
        NSString *duration = [[NSString alloc] initWithFormat:@"%0.0f:%02.0f", minutes, seconds];
        [_trackDuration setText:duration];
        [duration release];
        [self togglePlay];
    }
    [self toggleAudioControl:nil];
}

- (IBAction)togglePlay
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        [_pausePlayButton setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
        [_playbackTimer invalidate];
    } else {
        [_audioPlayer play];
        [_pausePlayButton setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
        _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

- (void)stopAudio
{
    [_audioPlayer stop];
    [_pausePlayButton setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
}

- (IBAction)moveScurbber:sender
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        [_audioPlayer setCurrentTime:_audioScrubber.value];
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        [_audioPlayer setCurrentTime:_audioScrubber.value];
        [_audioPlayer prepareToPlay];
        [self updateTime];
    }
}

- (void)updateTime
{
    float minutes = floor(_audioPlayer.currentTime / 60);
    float seconds = _audioPlayer.currentTime - (minutes * 60);
    
    NSString *duration = [[NSString alloc] initWithFormat:@"%0.0f:%02.0f", minutes, seconds];
    [_currentTime setText:duration];
    [duration release];
    
    [_audioScrubber setValue:_audioPlayer.currentTime];
}

- (IBAction)toggleAudioControl:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    if ([self.view alpha] == 0.0f) {
        [self.view setAlpha:1.0f];
    } else {
        [self.view setAlpha:0.0f];
    }
    
    [UIView commitAnimations];
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [_pausePlayButton setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
    }
}

- (void)dealloc
{
    [_audio release];
    [_audioPlayer release];
    [_audioScrubber release];
    [_pausePlayButton release];
    [_currentTime release];
    [_trackDuration release];
    [_trackTitle release];
    [_playbackTimer release];
    [super dealloc];
}

@end
