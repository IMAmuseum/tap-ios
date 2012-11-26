//
//  TranscriptStopController.h
//  Tap
//
//  Created by Daniel Cervantes on 11/4/12.
//
//

#import <UIKit/UIKit.h>

@class TAPTour, TAPStop, TAPAsset, TAPAssetRef, TAPConnection, TAPContent, TAPProperty, TAPSource;


@interface TranscriptStopController : UIViewController {
    IBOutlet UIImageView *bannerImage;
    
    TAPStop *transcriptStop;
    UITextView *transcript;
}

@property (nonatomic, retain) TAPStop *transcriptStop;
@property (nonatomic, retain) IBOutlet UITextView *transcript;

- (id)initWithStop:(TAPStop *)stop;
@end
