//
//  KeypadController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "StopNavigationViewController.h"

@interface KeypadViewController : StopNavigationViewController
{
    IBOutlet UIImageView *bannerImage;
	IBOutlet UILabel *lblCode;
	IBOutlet UIButton *btnGo;
	IBOutlet UIButton *btn0;
	IBOutlet UIButton *btn1;
	IBOutlet UIButton *btn2;
	IBOutlet UIButton *btn3;
	IBOutlet UIButton *btn4;
	IBOutlet UIButton *btn5;
	IBOutlet UIButton *btn6;
	IBOutlet UIButton *btn7;
	IBOutlet UIButton *btn8;
	IBOutlet UIButton *btn9;
	IBOutlet UIButton *btnClear;
}

@end
