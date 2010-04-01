#import <UIKit/UIKit.h>

#import "TapAppDelegate.h"

#define MINIMUM_CODE_LENGTH			2
#define MAXIMUM_CODE_LENGTH			5

@interface KeypadController : UIViewController {
	
	IBOutlet UIImageView *bannerImage;
	IBOutlet UILabel *lblCode;
	IBOutlet UIButton *buttonGo;
	IBOutlet UIButton *button0;
	IBOutlet UIButton *button1;
	IBOutlet UIButton *button2;
	IBOutlet UIButton *button3;
	IBOutlet UIButton *button4;
	IBOutlet UIButton *button5;
	IBOutlet UIButton *button6;
	IBOutlet UIButton *button7;
	IBOutlet UIButton *button8;
	IBOutlet UIButton *button9;
	IBOutlet UIButton *buttonClear;
	
}

// Event for down press to play a sound
- (IBAction)buttonDown:(id)sender;

// Event for pushing any numeric button or the clear button
- (IBAction)buttonUpInside:(id)sender;

// Event for pushing the GO button
- (IBAction)goUpInside:(id)sender;

// Clear the code from the text field
- (void)clearCode;

@end
