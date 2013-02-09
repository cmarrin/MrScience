//
//  ConversionsButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ConversionsButtonViewController.h"

#import "MainViewController.h"

@implementation ConversionsButtonViewController

- (void) updateConversions
{
    int clas = [m_fromConversionsView selectedRowInComponent:0];
    [m_fromConversions release];
    m_fromConversions = [[m_delegate.calculator conversionsForClass:clas index:[m_fromConversionsView selectedRowInComponent:1]] retain];
    [m_toConversions release];
    m_toConversions = [[m_delegate.calculator conversionsForClass:clas index:[m_toConversionsView selectedRowInComponent:0]] retain];
    [m_fromConversionsView selectRow:m_currentFromConversionForClass[clas] inComponent:1 animated:NO];
    [m_toConversionsView selectRow:m_currentToConversionForClass[clas] inComponent:0 animated:NO];
    [m_fromConversionsView reloadAllComponents];
    [m_toConversionsView reloadAllComponents];
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return [super initWithNibName:@"ConversionsButtonView" delegate:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView:self.view];

    // Init conversion arrays
    m_conversionClasses = [[m_delegate.calculator conversionTypes] retain];
    m_fromConversions = [[m_delegate.calculator conversionsForClass:0 index:0] retain];
    m_currentFromConversionForClass = malloc([m_conversionClasses count] * sizeof(int));
    memset(m_currentFromConversionForClass, 0, [m_conversionClasses count]);
    m_toConversions = [[m_delegate.calculator conversionsForClass:0 index:0] retain];
    m_currentToConversionForClass = malloc([m_conversionClasses count] * sizeof(int));
    memset(m_currentToConversionForClass, 0, [m_conversionClasses count]);
    
    [self updateConversions];
}

- (void)handleButton:(UIButton*) button
{
    switch(button.tag)
    {
        case buttonCNVConvert:
            [m_delegate.calculator convertWithClass:[m_fromConversionsView selectedRowInComponent:0]
                            fromIndex:[m_fromConversionsView selectedRowInComponent:1] 
                            toIndex:[m_toConversionsView selectedRowInComponent:0]];
            break;
        case buttonCNVBack:
            break;
        case buttonCNVToDegC:
            [m_delegate.calculator op:OP_CNV_DEGC];
            break;
        case buttonCNVToDegF:
            [m_delegate.calculator op:OP_CNV_DEGF];
            break;
        case buttonCNVToRad:
            [m_delegate.calculator op:OP_CNV_RAD];
            break;
        case buttonCNVToDeg:
            [m_delegate.calculator op:OP_CNV_DEG];
            break;
        case buttonCNVToHMS:
            [m_delegate.calculator op:OP_CNV_HMS];
            break;
        case buttonCNVToH:
            [m_delegate.calculator op:OP_CNV_H];
            break;
        case buttonCNVToPolar:
            [m_delegate.calculator op:OP_CNV_POLAR];
            break;
        case buttonCNVToRect:
            [m_delegate.calculator op:OP_CNV_RECT];
            break;
        default:
            [super handleButton:button];
            return;
    }

    [m_delegate showView:@"FirstButtonView"];
    
}

// UIPickerView delegate methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag)
        m_currentToConversionForClass[[m_fromConversionsView selectedRowInComponent:0]] = row;
    else if (component)
        m_currentFromConversionForClass[[m_fromConversionsView selectedRowInComponent:0]] = row;
    else
        [self updateConversions];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return (pickerView.tag == 0 && component == 0) ? 85 : 65;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag)
        return [m_toConversions count];
    return component ? [m_fromConversions count] : [m_conversionClasses count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval)
        retval= [[[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 10, [pickerView rowSizeForComponent:component].height)] autorelease];

    retval.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    retval.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    retval.text = pickerView.tag ? [m_toConversions objectAtIndex:row] : (component ? [m_fromConversions objectAtIndex:row] : [m_conversionClasses objectAtIndex:row]);
    return retval;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return thePickerView.tag ? 1 : 2;
}

@end
