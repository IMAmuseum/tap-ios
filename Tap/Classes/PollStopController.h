#import <UIKit/UIKit.h>

#import "PollStop.h"
#import "PollResults.h"


@interface PollStopController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	IBOutlet UILabel *questionLabel;
	IBOutlet UIPickerView *pickerView;
	IBOutlet UIButton *submitButton;
	
	PollStop *pollStop;
	NSMutableData *responseData;
    NSTimer *delayTimer;

}

@property (nonatomic, retain) UILabel *questionLabel;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIButton *submitButton;

@property (assign) PollStop *pollStop;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSTimer *delayTimer;

// Event for submission of the poll
- (IBAction)submitPressed:(id)sender;

- (id)initWithPollStop:(PollStop*)stop;

- (void)showResults:(NSTimer*)timer;

@end
