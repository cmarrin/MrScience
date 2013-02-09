//
//  MainViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MainViewController.h"

#import "Calculator.h"

@implementation MainViewController

@synthesize calculator = m_calculator;

- (NSString*)currentPrompt { return m_currentPrompt; }
- (NSString*)currentString { return m_currentString; }
- (OperationType)currentOp { return m_currentOp; }
- (BOOL)hyperbolic { return m_hyperbolic; }

- (void)setCurrentPrompt:(NSString*) prompt
{
    [prompt retain];
    [m_currentPrompt release];
    m_currentPrompt = prompt;
    [m_calculator notifyUpdate];
}

- (void)setCurrentString:(NSString*) string
{
    [string retain];
    [m_currentString release];
    m_currentString = string;
    [m_calculator notifyUpdate];
}

- (void)setCurrentOp:(OperationType) op
{
    m_currentOp = op;
    [m_calculator notifyUpdate];
}

- (void)setHyperbolic:(BOOL) hyperbolic
{
    m_hyperbolic = hyperbolic;
    [m_calculator notifyUpdate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)showMode
{
    if (m_calculator.base == DEC)
        switch(m_calculator.mode) {
            case DEG: m_modeDisplay.text = @"Deg"; break;
            case RAD: m_modeDisplay.text = @"Rad"; break;
            case GRAD: m_modeDisplay.text = @"Grad"; break;
        }
    else
         m_modeDisplay.text = @"";
}

- (void)showDisp
{
    if (m_calculator.base == DEC)
        switch(m_calculator.disp) {
            case ALL: m_dispDisplay.text = @"All"; break;
            case FIX: m_dispDisplay.text = [NSString stringWithFormat:@"Fix %d", m_calculator.dispSignificantDigits]; break;
            case SCI: m_dispDisplay.text = [NSString stringWithFormat:@"Sci %d", m_calculator.dispSignificantDigits]; break;
            case ENG: m_dispDisplay.text = [NSString stringWithFormat:@"Eng %d", m_calculator.dispSignificantDigits]; break;
        }
    else
        switch(m_calculator.base) {
            case DEC: break;
            case HEX: m_dispDisplay.text = @"Hex"; break;
            case BIN: m_dispDisplay.text = @"Bin"; break;
            case OCT: m_dispDisplay.text = @"Oct"; break;
        }
}

- (NSString*)stringFromNumber:(Number*) number
{
    return [number stringInBase:m_calculator.base format:m_calculator.disp precision:m_calculator.dispSignificantDigits];
}

- (void) updateDisplay
{
    if (m_calculator.inputMode != IM_NONE)
        [self showView:@"FirstButtonView"];
        
    if (m_calculator.runState != RS_RUNNING || ![m_xRegisterDisplay.text isEqualToString:@"Running..."]) {
        [self showMode];
        [self showDisp];
        
        // Update info display
        BOOL error = NO;
        NSString* s = @"";
        
        if (m_calculator.inputMode != IM_NONE)
            s = m_calculator.inputPrompt;
        else if (m_currentPrompt)
            s = m_currentPrompt;
        else {
            if (m_calculator.programming)
                s = [s stringByAppendingString:@"PROG "];
            else if (m_calculator.stepping)
                s = [s stringByAppendingString:@"STEP "];

            if (!m_calculator.stepping) {
                if (m_calculator.runState == RS_STOPPED)
                    s = [s stringByAppendingString:@"STOPPED "];
                else if (m_calculator.runState == RS_PAUSED)
                    s = [s stringByAppendingString:@"PAUSE "];
            }
            
            if (m_hyperbolic)
                s = [s stringByAppendingString:@"HYP "];
        }
            
        m_infoDisplay.text = s;
        m_infoDisplay.textColor = error ? [UIColor colorWithRed:1 green:0 blue:0 alpha:1] :
                                          [UIColor colorWithRed:1 green:0.5f blue:0 alpha:1];
        
        // X register shows (in order of existance):
        //
        //  - "Running..." if runState == RS_RUNNING
        //  - m_currentString if it is not nil
        //  - m_calculator.x
        if (m_calculator.runState == RS_RUNNING)
            m_xRegisterDisplay.text = @"Running...";
        else if (m_currentString)
            m_xRegisterDisplay.text = m_currentString;
        else
            m_xRegisterDisplay.text = [self stringFromNumber:m_calculator.x];
    }
    
    // Update number displays
    m_yRegisterDisplay.text = [self stringFromNumber:m_calculator.y];
    m_zRegisterDisplay.text = [self stringFromNumber:m_calculator.z];
    m_tRegisterDisplay.text = [self stringFromNumber:m_calculator.t];
    m_lastXRegisterDisplay.text = [self stringFromNumber:m_calculator.lastX];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // Init main InstructionUnit
    m_calculator = [[Calculator alloc] init];
    
    // Show the right buttons
    [self showView:@"FirstButtonView"];
        
    [m_calculator addUpdateNotificationWithTarget:self selector:@selector(updateDisplay)];

    // Init display
    [self updateDisplay];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showInfoFile:(NSString*) filename
{
    if (self.modalViewController)
        [self dismissModalViewControllerAnimated:NO];
        
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
    
    [controller setInfoFilename:filename];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (IBAction)showInfo
{
    NSString* helpFilename = [[NSBundle mainBundle] pathForResource:@"Help" ofType:@"html"];
    [self showInfoFile:helpFilename];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc
{
    [m_calculator removeAllUpdateNotificationsForTarget:self];
    [m_calculator release];
    m_calculator = nil;
    [super dealloc];
}

- (void)cleanup
{
    [m_calculator cleanup];
}

- (void)finishViewAnimation:(NSString*) animationID finished:(NSNumber*) finished context:(void*) context 
{
    if ([[m_placeholderView subviews] count] > 1)
        [[[m_placeholderView subviews] objectAtIndex:0] removeFromSuperview];
}

- (void)showView:(NSString*) view
{
    Class viewClass = NSClassFromString([view stringByAppendingString:@"Controller"]);
    
    if ([m_currentViewController isKindOfClass:viewClass]) {
        if (![m_currentViewController viewChanged])
            return;
    }
    else {
        [m_currentViewController autorelease];
        m_currentViewController = [viewClass alloc];
    }
    
    if ([m_currentViewController respondsToSelector:@selector(initWithDelegate:)])
        [m_currentViewController initWithDelegate:self];
    else
        [m_currentViewController init];
    
    if (![m_currentViewController respondsToSelector:@selector(modal)] || [m_currentViewController modal]) {
        // If we're going from one modal view to another, first cancel the old one
        if (self.modalViewController)
            [self dismissModalViewControllerAnimated:NO];
    
        [self presentModalViewController:m_currentViewController animated:YES];
        return;
    }
    
    if (self.modalViewController) {
        // We are showing a modal view, just pop the buttons in and get rid of the modal view
        if ([[m_placeholderView subviews] count])
            [[[m_placeholderView subviews] objectAtIndex:0] removeFromSuperview];
            
        [m_placeholderView addSubview:m_currentViewController.view];
        m_currentViewController.view.alpha = 1;
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    [m_placeholderView addSubview:m_currentViewController.view];
    
    // Don't animate if we adding the first subview
    if ([[m_placeholderView subviews] count] == 1) {
        m_currentViewController.view.alpha = 1;
        return;
    }
    
    // Going from one button view to another
    m_currentViewController.view.alpha = 0;
	[UIView beginAnimations:@"ButtonViewAnimation" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishViewAnimation:finished:context:)];
	[UIView setAnimationDuration:0.3];
    m_currentViewController.view.alpha = 1;
    [UIView commitAnimations];
}

@end
