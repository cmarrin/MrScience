//
//  ConversionsButtonViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

@interface ConversionsButtonViewController : ButtonViewController {
    IBOutlet UIPickerView* m_fromConversionsView;
    IBOutlet UIPickerView* m_toConversionsView;
    
    // Stored title arrays for current from and to lists
    NSArray* m_conversionClasses;
    NSArray* m_fromConversions;
    int* m_currentFromConversionForClass;
    NSArray* m_toConversions;
    int* m_currentToConversionForClass;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
