//
//  ButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

#import "Calculator.h"

#import <AVFoundation/AVFoundation.h>

@implementation ButtonViewController

static AVAudioPlayer* clickPlayer;

+ (void)playClick
{
    [clickPlayer play];
}

- (void)buttonPressed:(UIButton*) button
{
    [ButtonViewController playClick];
}

- (void)initializeView:(UIView*) view
{
    // Init button callbacks
    for (UIButton* button in view.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    view.alpha = 0;
    
    if (!clickPlayer) {
        NSString* soundFilename = [[NSBundle mainBundle] pathForResource:@"buttonClick" ofType:@"wav"];
        NSURL* soundFileURL = [[NSURL fileURLWithPath:soundFilename] retain];
        
        NSError* error;
        clickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        
        // This sequence will prime the sound without an audible click on startup
        [clickPlayer prepareToPlay];
        clickPlayer.volume = 0;
        [clickPlayer play];
        clickPlayer.volume = 0.1f;
    }
}

- (void)viewDidLoad
{
    [self initializeView:self.view];
}

- (void)handleButton:(UIButton*) button
{
    NSString* view = @"FirstButtonView";
    
    switch(button.tag) {
        case buttonRollDown:
            [m_delegate.calculator op:OP_ROLL_DN];
            break;
        case buttonEnter:
            [m_delegate.calculator op:OP_ENTER];
            break;
        case buttonExch:
            [m_delegate.calculator op:OP_EXCH];
            break;
            
        case buttonC:
            [m_delegate.calculator op:OP_CLR_X];
            break;

        case buttonSto:
            m_delegate.currentOp = OP_STO;
            m_delegate.currentPrompt = @"Enter id of reg to store into";
            view = @"RegButtonView";
            break;
        case buttonRcl:
            m_delegate.currentOp = OP_RCL;
            m_delegate.currentPrompt = @"Enter id of reg to recall";
            view = @"RegButtonView";
            break;
        
        case button2nd:
            view = @"SecondButtonView";
            break;
        case buttonFUN:
            view = @"FunctionButtonView";
            break;
        case buttonPRG:
            view = @"ProgrammingView";
            break;
        
        case buttonDivide:
            [m_delegate.calculator op:OP_DIV];
            break;
        case buttonMuliply:
            [m_delegate.calculator op:OP_MUL];
            break;
        case buttonSubtract:
            [m_delegate.calculator op:OP_SUB];
            break;
        case buttonAdd:
            [m_delegate.calculator op:OP_ADD];
            break;
        case buttonSqrtX:
            [m_delegate.calculator op:OP_SQRT];
            break;
        case buttonEToTheX:
            [m_delegate.calculator op:OP_E_TO_THE_X];
            break;
        case buttonLN:
            [m_delegate.calculator op:OP_LN];
            break;
        case buttonYToTheX:
            [m_delegate.calculator op:OP_Y_TO_THE_X];
            break;
        case buttonOneOverX:
            [m_delegate.calculator op:OP_1_OVER_X];
            break;
        case buttonSummation:
            [m_delegate.calculator op:OP_SUM];
            break;
        case buttonSin:
            [m_delegate.calculator op:m_delegate.hyperbolic ? OP_SINH : OP_SIN];
            break;
        case buttonCos:
            [m_delegate.calculator op:m_delegate.hyperbolic ? OP_COSH : OP_COS];
            break;
        case buttonTan:
            [m_delegate.calculator op:m_delegate.hyperbolic ? OP_TANH : OP_TAN];
            break;

        case buttonRS:
            if (m_delegate.calculator.runState == RS_PAUSED || m_delegate.calculator.runState == RS_RUNNING)
                [m_delegate.calculator stop];
            else
                [m_delegate.calculator run];
            break;
            
        case buttonRollUp:
            [m_delegate.calculator op:OP_ROLL_UP];
            break;
        case buttonLastX:
            [m_delegate.calculator op:OP_LAST_X];
            break;
            
        case buttonClearSTACK:
            [m_delegate.calculator op:OP_CLR_STACK];
            break;
        case buttonClearVARS: {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Clearing register variables" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];	
            [alert release];
            return;
        }
        case buttonClearPGM:
            // If the current program hasn't been named, put up a dialog which offers to name it.
            if ([m_delegate.calculator.title length] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Current program is unnamed" message:@"Set name or overwrite?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Set name", @"Overwrite", nil];
                [alert show];	
                [alert release];
                return;
            }
            else
                [m_delegate.calculator op:OP_CLR_PGM];
            break;
        case buttonClearSUM:
            [m_delegate.calculator op:OP_CLR_SUM];
            break;

        case buttonPI:
            [m_delegate.calculator op:OP_PI];
            break;
        case buttonHYP:
            m_delegate.hyperbolic = !m_delegate.hyperbolic;
            break;
        
        case button2ndBack:
            break;
        
        case buttonBaseDEC:
            [m_delegate.calculator op:OP_BASE_DEC];
            view = @"FirstButtonView";
            break;
        case buttonBaseHEX:
            [m_delegate.calculator op:OP_BASE_HEX];
            view = @"FirstButtonView";
            break;
        case buttonBaseBIN:
            [m_delegate.calculator op:OP_BASE_BIN];
            view = @"FirstButtonView";
            break;
        case buttonBaseOCT:
            [m_delegate.calculator op:OP_BASE_OCT];
            view = @"FirstButtonView";
            break;
        
        case buttonXSquared:
            [m_delegate.calculator op:OP_X_SQUARED];
            break;
        case button10ToTheX:
            [m_delegate.calculator op:OP_10_TO_THE_X];
            break;
        case buttonLOG:
            [m_delegate.calculator op:OP_LOG];
            break;
        case buttonLOG2:
            [m_delegate.calculator op:OP_LOG_2];
            break;
        case button2ToTheX:
            [m_delegate.calculator op:OP_2_TO_THE_X];
            break;
        case buttonXRootOfY:
            [m_delegate.calculator op:OP_X_ROOT_OF_Y];
            break;
        case buttonXFactorial:
            [m_delegate.calculator op:OP_X_FACTORIAL];
            break;
        case buttonPercent:
            [m_delegate.calculator op:OP_PCT];
            break;
        case buttonDeltaPercent:
            [m_delegate.calculator op:OP_DELTA_PCT];
            break;
        case buttonSummationMinus:
            [m_delegate.calculator op:OP_SUM_MINUS];
            break;
        case buttonASin:
            [m_delegate.calculator op:m_delegate.hyperbolic ? OP_ARCSINH : OP_ARCSIN];
            break;
        case buttonACos:
            [m_delegate.calculator op:m_delegate.hyperbolic ? OP_ARCCOSH : OP_ARCCOS];
            break;
        case buttonATan:
            [m_delegate.calculator op:m_delegate.hyperbolic ? OP_ARCTANH : OP_ARCTAN];
            break;

        case buttonRound:
            [m_delegate.calculator op:OP_ROUND];
            break;
        case buttonTrunc:
            [m_delegate.calculator op:OP_TRUNC];
            break;
        case buttonFrac:
            [m_delegate.calculator op:OP_FRAC];
            break;
        case buttonAbs:
            [m_delegate.calculator op:OP_ABS];
            break;

        case buttonHexAND:
            [m_delegate.calculator op:OP_HEX_AND];
            break;
        case buttonHexOR:
            [m_delegate.calculator op:OP_HEX_OR];
            break;
        case buttonHexXOR:
            [m_delegate.calculator op:OP_HEX_XOR];
            break;
        case buttonHexNEG:
            [m_delegate.calculator op:OP_HEX_NEG];
            break;
        case buttonHexNOT:
            [m_delegate.calculator op:OP_HEX_NOT];
            break;
        case buttonHexSHL:
            [m_delegate.calculator op:OP_HEX_SHL];
            break;
        case buttonHexSHR:
            [m_delegate.calculator op:OP_HEX_SHR];
            break;
        case buttonHexMOD:
            [m_delegate.calculator op:OP_HEX_MOD];
            break;

        case buttonFUNRand:
            [m_delegate.calculator op:OP_RAND];
            break;
        case buttonFUNSeed:
            [m_delegate.calculator op:OP_SEED];
            break;

        case buttonFUNXMean:
            [m_delegate.calculator op:OP_X_MEAN];
            break;
        case buttonFUNYMean:
            [m_delegate.calculator op:OP_Y_MEAN];
            break;
        case buttonFUNXWMean:
            [m_delegate.calculator op:OP_XW_MEAN];
            break;
        case buttonFUNPSDX:
            [m_delegate.calculator op:OP_PSD_X];
            break;
        case buttonFUNPSDY:
            [m_delegate.calculator op:OP_PSD_Y];
            break;
        case buttonFUNSSDX:
            [m_delegate.calculator op:OP_SSD_X];
            break;
        case buttonFUNSSDY:
            [m_delegate.calculator op:OP_SSD_Y];
            break;
        case buttonFUNCnr:
            [m_delegate.calculator op:OP_C_N_R];
            break;
        case buttonFUNPnr:
            [m_delegate.calculator op:OP_P_N_R];
            break;
        
        case buttonFUNDup2:
            [m_delegate.calculator op:OP_DUP2];
            break;
        case buttonFUNOver:
            [m_delegate.calculator op:OP_OVER];
            break;
        case buttonFUNSolve:
            [m_delegate.calculator op:OP_SOLVE];
            break;

        case buttonFUNCNV:
            view = @"ConversionsButtonView";
            break;
        case buttonFUNBack:
            break;

        default: return;
    }
    
    if (button.tag != button2nd && button.tag != buttonHYP)
        m_delegate.hyperbolic = NO;
    
    if (view)
        [m_delegate showView:view];
}

// UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Clearing register variables"]) {
        // button 0 means we want to cancel, 1 means we want to clear
        if (buttonIndex != 0)
            [m_delegate.calculator op:OP_CLR_VARS];
    }
    else if ([alertView.title isEqualToString:@"Current program is unnamed"]) {
        // button index 0 means we want to cancel, 1 means we want to name the current program, 2 means we want to overwrite
        if (buttonIndex == 1)
            [m_delegate showView:@"StoreView"];
        else if (buttonIndex == 2)
            [m_delegate.calculator op:OP_CLR_PGM];
    }
    
    [m_delegate showView:@"FirstButtonView"];
}

@end
