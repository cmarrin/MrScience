//
//  EditViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ViewControllerBase.h"

@interface EditViewController : TableViewControllerBase<UITextViewDelegate, UITextFieldDelegate> {
    NSString* m_key;
    NSString* m_string;
    id m_editor;
}

- (id)initWithKey:(NSString*) key delegate:(id<ControllerProtocol>) d;

@end
