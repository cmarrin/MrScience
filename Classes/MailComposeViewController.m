//
//  MailComposeViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MailComposeViewController.h"

@implementation MailComposeViewController

- (BOOL)modal
{
    return YES;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    [super init];
    m_delegate = d;
    self.mailComposeDelegate = self;
    
    [self setSubject:@"[MrScience] New Program Submitted"];
    [self setToRecipients:[NSArray arrayWithObject:@"chris@marrin.com"]];

    NSString* body = @"Here is a program submitted by a MrScience user\n----------------\n";
    body = [body stringByAppendingString:[m_delegate.calculator programToPropertyListString]];
    body = [body stringByAppendingString:@"\n----------------\n"];
    body = [body stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
    [self setMessageBody:body isHTML:NO];
    
    return self;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [m_delegate showView:@"FunctionButtonView"];
}

@end
