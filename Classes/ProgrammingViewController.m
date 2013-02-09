//
//  ProgrammingViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ProgrammingViewController.h"

#import "MainViewController.h"
#import "ExecutionUnit.h"

@interface TableHeaderView : UIView {
    ProgrammingViewController* m_delegate;
}

@property(assign) ProgrammingViewController* delegate;

@end

@implementation TableHeaderView

@synthesize delegate = m_delegate;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if(touch.tapCount == 2) {
        [m_delegate keepSelectedLineVisible];
    }
    [super touchesEnded:touches withEvent:event];
}

@end

@implementation ProgramTableView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if(touch.tapCount == 2) {
        UIView* view = [touch.view superview];
        if ([view isKindOfClass:[UITableViewCell class]])
            [(ProgrammingViewController*) self.delegate selectCell:(UITableViewCell*) view];
    }
    [super touchesEnded:touches withEvent:event];
}

@end

@interface ProgrammingViewController (Private)

- (void)updateDisplay;

@end

@implementation ProgrammingViewController

- (BOOL)modal
{
    return YES;
}

static BOOL buttonInList(int button, int* list, int count)
{
    for (int i = 0; i < count; ++i)
        if (list[i] == button)
            return YES;
    return NO;
}

- (void)setButtonsEnabled:(BOOL) enabled
{
    static int buttons[] = {
        buttonPRGIf, buttonPRGElse, buttonPRGThen, buttonPRGEQ, buttonPRGNE, buttonPRGLT, buttonPRGGT, 
        buttonPRGLE, buttonPRGGE, buttonPRGFor, buttonPRGDo, buttonPRGBreak, buttonPRGBreakIf, buttonPRGLoop, 
        buttonPRGCall, buttonPRGRet, buttonPRGRetIf, buttonPRGInput, buttonPRGPause, -1
    };
    
    static int buttonsSize = sizeof(buttons) / sizeof(int);
    
    for (UIButton* button in self.view.subviews) {
        if ([button isKindOfClass:[UIButton class]] && buttonInList(button.tag, buttons, buttonsSize))
            button.enabled = enabled;
    }
}

- (void)setSelectedFunc:(NSUInteger) func inst:(NSUInteger) inst
{
    m_selectedFunc = func;
    m_selectedInst = inst;
    [m_tableView reloadData];
    [self keepSelectedLineVisible];
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return [super initWithNibName:@"ProgrammingView" delegate:d];
}

- (void)dealloc
{
    [m_delegate.calculator removeAllUpdateNotificationsForTarget:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_tableWidth = m_tableView.frame.size.width;
    m_tableHeaderHeight = m_tableView.sectionHeaderHeight;
    m_tableRowHeight = m_tableView.rowHeight;

    self.view.alpha = 1;
    
    [m_delegate.calculator addUpdateNotificationWithTarget:self selector:@selector(updateDisplay)];
    [self updateDisplay];
}

- (void)handleButton:(UIButton*) button
{
    switch(button.tag) {
        case buttonPRGDelFunc: {
            // Verify
            NSString* name;
            int key;
            [m_delegate.calculator currentFunctionName:&name key:&key];
            NSString* title;
            
            if (key == 0)
                title = @"Deleting anonymous function";
            else if (key < 0)
                title = [NSString stringWithFormat:@"Deleting subroutine \'%@\'", name];
            else
                title = [NSString stringWithFormat:@"Deleting function \'%@\'", name];
                
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];	
            [alert release];
            break;
        }
        case buttonPRGIf: [m_delegate.calculator op:OP_IF]; break;
        case buttonPRGElse: [m_delegate.calculator op:OP_ELSE]; break;
        case buttonPRGThen: [m_delegate.calculator op:OP_THEN]; break;
        case buttonPRGFor: [m_delegate.calculator op:OP_FOR]; break;
        case buttonPRGDo: [m_delegate.calculator op:OP_DO]; break;
        case buttonPRGBreak: [m_delegate.calculator op:OP_BREAK]; break;
        case buttonPRGBreakIf: [m_delegate.calculator op:OP_BREAKIF]; break;
        case buttonPRGLoop: [m_delegate.calculator op:OP_LOOP]; break;
        case buttonPRGEQ: [m_delegate.calculator op:OP_EQ]; break;
        case buttonPRGNE: [m_delegate.calculator op:OP_NE]; break;
        case buttonPRGLT: [m_delegate.calculator op:OP_LT]; break;
        case buttonPRGGT: [m_delegate.calculator op:OP_GT]; break;
        case buttonPRGLE: [m_delegate.calculator op:OP_LE]; break;
        case buttonPRGGE: [m_delegate.calculator op:OP_GE]; break;
        case buttonPRGRet: [m_delegate.calculator op:OP_RET]; break;
        case buttonPRGRetIf: [m_delegate.calculator op:OP_RETIF]; break;
        
        case buttonPRGFunc:
            if ([m_delegate.calculator canAssignUserKey]) {
                m_delegate.currentOp = OP_DEF_FUNC;
                m_delegate.currentPrompt = @"Enter func id (8 chars max)";
                [m_delegate showView:@"AlphanumericButtonView"];
            }
            else {
                // Alert that there are no keys available
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No available user keys" message:@"First remove an existing function" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];	
                [alert release];
            }
            break;
        case buttonPRGSubr:
            m_delegate.currentOp = OP_DEF_SUBR;
            m_delegate.currentPrompt = @"Enter subr reg id";
            [m_delegate showView:@"RegButtonView"];
            break;
        case buttonPRGCall:
            m_delegate.currentOp = OP_CALL;
            m_delegate.currentPrompt = @"Enter reg id of subr to call";
            [m_delegate showView:@"RegButtonView"];
            break;
        case buttonPRGNew:
            [m_delegate.calculator addFunction];
            break;
        case buttonPRGInput:
            m_delegate.currentOp = OP_INPUT;
            m_delegate.currentPrompt = @"Enter input prompt";
            [m_delegate showView:@"AlphanumericButtonView"];
            break;
        case buttonPRGPause:
            [m_delegate.calculator op:OP_PAUSE];
            break;
        
        case buttonPRGQUIT:
            [m_delegate.calculator quit];
            break;
        case buttonPRGDEL:
            [m_delegate.calculator deleteCurrentInstruction];
            break;
        case buttonPRGADD:
            m_delegate.calculator.programming = !m_delegate.calculator.programming;
            break;
        case buttonPRGSTEP:
                [m_delegate.calculator step];
            break;

        case buttonRS:
            if (m_delegate.calculator.runState == RS_PAUSED || m_delegate.calculator.runState == RS_RUNNING)
                [m_delegate.calculator stop];
            else
                [m_delegate.calculator run];
            break;
            
        case buttonPRGBack:
            [m_delegate showView:@"FirstButtonView"];
            break;
        default:
            [super handleButton:button];
            return;
    }
}

- (void)selectCell:(UITableViewCell*) cell
{
    if (m_delegate.calculator.stepping)
        return;
        
    [m_delegate.calculator quit];
    [self setSelectedFunc:cell.tag >> 16 inst:cell.tag & 0xffff];
    [m_delegate.calculator selectFunction:cell.tag >> 16 instruction:cell.tag & 0xffff];
}

- (void)keepSelectedLineVisible
{
    if ([m_tableView numberOfSections] <= (int) m_selectedFunc || [m_tableView numberOfRowsInSection:m_selectedFunc] <= (int) m_selectedInst)
        return;
        
    NSIndexPath* path = [NSIndexPath indexPathForRow:m_selectedInst inSection:m_selectedFunc];
    [m_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)updateDisplay
{
    if (m_delegate.calculator.runState == RS_RUNNING && [m_xRegisterDisplay.text isEqualToString:@"Running..."])
        return;
    
    NSString* s = @"";
    
    if (m_delegate.calculator.programming)
        s = [s stringByAppendingString:@"PROG "];
    else if (m_delegate.calculator.stepping)
        s = [s stringByAppendingString:@"STEP "];

    if (!m_delegate.calculator.stepping) {
        if (m_delegate.calculator.runState == RS_STOPPED)
            s = [s stringByAppendingString:@"STOPPED "];
        else if (m_delegate.calculator.runState == RS_PAUSED)
            s = [s stringByAppendingString:@"PAUSE "];
    }
    
    if (m_delegate.hyperbolic)
        s = [s stringByAppendingString:@"HYP "];
    
    m_infoDisplay.text = s;
    m_infoDisplay.textColor = [UIColor colorWithRed:1 green:0.5f blue:0 alpha:1];
    
    if (m_delegate.calculator.runState == RS_RUNNING)
        m_xRegisterDisplay.text = @"Running...";
    else
        m_xRegisterDisplay.text = (m_delegate.calculator.runState == RS_RUNNING) ? @"Running..." :
            [m_delegate.calculator.x stringInBase:m_delegate.calculator.base format:m_delegate.calculator.disp precision:m_delegate.calculator.dispSignificantDigits];

    if (m_delegate.calculator.runState != RS_RUNNING) {
        if (m_delegate.calculator.stepping)
            [self setSelectedFunc:m_delegate.calculator.executingFunction inst:m_delegate.calculator.executingInstruction];
        else
            [self setSelectedFunc:m_delegate.calculator.currentFunction inst:m_delegate.calculator.currentInstruction];
    }
    
    m_addButton.selected = m_delegate.calculator.programming;
    
    [self setButtonsEnabled:m_delegate.calculator.programming];
}

// TableView support
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [m_delegate.calculator.program count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[m_delegate.calculator.program objectAtIndex:section] objectForKey:@"inst"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"MyCell";
    
    NSUInteger funcIndex = indexPath.section;
    NSUInteger instIndex = indexPath.row;
    BOOL selected = funcIndex == m_selectedFunc && instIndex == m_selectedInst;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[[UILabel alloc] init] autorelease];
        CGFloat textHeight = m_tableRowHeight * 0.75f;
        label.frame = CGRectMake(5, (m_tableRowHeight - textHeight) / 2, m_tableWidth - 10, textHeight);
        label.font = [UIFont fontWithName:@"Helvetica" size:textHeight];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumFontSize = textHeight * 0.75f;
        label.lineBreakMode = UILineBreakModeMiddleTruncation;
        label.tag = 99999;
        
        [cell.contentView addSubview:label];
    }

    cell.tag = (funcIndex << 16) + (instIndex & 0xffff);
    cell.backgroundColor = [UIColor clearColor];
    
    if (selected)
        cell.contentView.backgroundColor = (m_delegate.calculator.stepping) ? 
             [UIColor colorWithRed:1 green:0.75f blue:0.5f alpha:1] : [UIColor colorWithRed:0.8f green:0.77f blue:0.75f alpha:1];
    else
        cell.contentView.backgroundColor = [UIColor whiteColor];

    UILabel* label = (UILabel*) [cell.contentView viewWithTag:99999];
    label.backgroundColor = [UIColor clearColor];
    
    NSArray* inst = [[m_delegate.calculator.program objectAtIndex:funcIndex] objectForKey:@"inst"];
    
    // Need to get rid of anything past '|'
    label.text = [[[inst objectAtIndex:instIndex] componentsSeparatedByString:@"|"] objectAtIndex:0];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return m_tableHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* func = [m_delegate.calculator.program objectAtIndex:section];
    int key = [[func objectForKey:@"key"] intValue];
    NSString* type = (key > 0) ? @"func" : (key ? @"subr" : @"");
    
    NSString* name;
    
    if (key < 0) {
        // extract a name string from the reg index
        int reg = [[func objectForKey:@"name"] intValue];
        name = [ExecutionUnit stringFromReg:reg];
    }
    else
        name = [func objectForKey:@"name"];
    
    CGFloat nameTextHeight = m_tableHeaderHeight * 0.75f;
    CGFloat typeTextHeight = m_tableHeaderHeight * 0.5f;
    CGFloat typeWidth = typeTextHeight * 2.8f; 
    
    UILabel *nameLabel = [[[UILabel alloc] init] autorelease];
    nameLabel.frame = CGRectMake(typeWidth + 5, (m_tableHeaderHeight - nameTextHeight) / 2, m_tableWidth - typeWidth - 10, nameTextHeight);
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    nameLabel.shadowColor = [UIColor blackColor];
    nameLabel.shadowOffset = CGSizeMake(0, 1);
    nameLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:nameTextHeight];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.minimumFontSize = nameTextHeight * 0.5f;
    nameLabel.text = key ? name : @"";

    CGFloat typeYOffset = (m_tableHeaderHeight - typeTextHeight) / 2;
    UILabel *typeLabel = [[[UILabel alloc] init] autorelease];
    typeLabel.frame = CGRectMake(3, typeYOffset, typeWidth, typeTextHeight);
    typeLabel.backgroundColor = [UIColor clearColor];
    typeLabel.textColor = [UIColor colorWithRed:1 green:0.5f blue:0 alpha:1];
    typeLabel.shadowOffset = CGSizeMake(0, 0);
    typeLabel.font = [UIFont fontWithName:@"Helvetica" size:typeTextHeight];
    typeLabel.text = (key > 0) ? [type stringByAppendingFormat:@":%d", key] : type;

    // Create header view and add label as a subview
    TableHeaderView *view = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, m_tableWidth, m_tableHeaderHeight)];
    view.delegate = self;
    view.tag = section;
    
    NSString* imageName = [[NSBundle mainBundle] pathForResource:(section == (int) m_selectedFunc) ? @"gradient_bright" : @"gradient" ofType:@"png"];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:imageName];
    
    view.backgroundColor = [UIColor colorWithPatternImage:image];
    [view autorelease];
    [view addSubview:typeLabel];
    [view addSubview:nameLabel];

    return view;
}

// UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // For now we assume this is the delete function alert
    if (buttonIndex > 0)
        [m_delegate.calculator deleteCurrentFunction];
}

@end
