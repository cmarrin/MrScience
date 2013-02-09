//
//  StoreEditViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "EditViewController.h"

@implementation EditViewController

- (id)initWithKey:(NSString*) key delegate:(id<ControllerProtocol>) d
{
    m_key = [key retain];
    m_string = [[d.calculator valueForKey:key] retain];
    [super initWithStyle:UITableViewStyleGrouped delegate:d];
    self.tableView.scrollEnabled = NO;
    return self;
}

- (void)dealloc
{
    [m_string release];
    [m_key release];
    [m_editor release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    // resignFirstResponder so we get the final text
    [m_editor resignFirstResponder];
    [m_delegate.calculator setValue:m_string forKey:m_key];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)] autorelease];
}

// TableView datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellType = ([m_key isEqualToString:@"description"]) ? @"TextViewCell" : @"TextFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellType] autorelease];
        if ([m_key isEqualToString:@"description"]) {
            UITextView* textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, 280, 170)];
            textView.text = m_string;
            textView.font = [UIFont fontWithName:@"Helvetica" size:15];
            textView.delegate = self;
            NSRange r  = {0,0};
            [textView setSelectedRange:r];
            [cell.contentView addSubview:textView];
            [textView becomeFirstResponder];
            m_editor = textView;
        }
        else {
            UITextField* textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 2, 280, 24)];
            textField.text = m_string;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
            [textField becomeFirstResponder];
            m_editor = textField;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    return [m_key isEqualToString:@"description"] ? 180 : 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [m_string release];
    m_string = [textView.text retain];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [m_string release];
    m_string = [textField.text retain];
}

@end
