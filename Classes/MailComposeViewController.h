//
//  MailComposeViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ViewControllerBase.h"

#import <MessageUI/MFMailComposeViewController.h>

@interface MailComposeViewController : MFMailComposeViewController <MFMailComposeViewControllerDelegate> {
	id<ControllerProtocol>  m_delegate;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
