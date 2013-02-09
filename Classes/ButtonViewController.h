//
//  ButtonViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ViewControllerBase.h"

#import "Buttons.h"

@interface ButtonViewController : ViewControllerBase {
}

+ (void)playClick;

- (void)initializeView:(UIView*) view;
- (void)handleButton:(UIButton*) button;

@end
