//
//  DetailViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "DetailViewController.h"

#import "EditViewController.h"

@implementation DetailViewController

- (void)done
{
    [m_delegate showView:@"FunctionButtonView"];
}

- (NSString*) escapeString:(NSString*) s
{
    s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"];
    s = [s stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    return s;
}

- (NSString*) mailtoStringForCurrentProgram:(NSString*) to subject:(NSString*) subject body:(NSString*) body
{
    NSString* plist = [m_delegate.calculator programToPropertyListString];
    
    NSString* s = @"mailto:";
    s = [s stringByAppendingString:to];
    s = [s stringByAppendingString:@"?subject="];
    s = [s stringByAppendingString:subject];
    s = [s stringByAppendingString:@"&body="];
    s = [s stringByAppendingString:body];
    s = [s stringByAppendingString:@"\n\n"];
    s = [s stringByAppendingString:plist];
    s = [s stringByAppendingString:@"\n"];
    NSString* ss = [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    s = [self escapeString:s];
    NSLog(@"%@\n", s);
    return ss;
}

- (void)rightButton
{
    switch (m_detailType) {
        case ADD:
            [m_delegate.calculator setProgramDescriptor:m_details];
            break;
        case LOAD:
            [m_delegate.calculator loadProgram:[m_details valueForKey:@"title"] withCategory:[m_details valueForKey:@"category"]];
            break;
        case STORE:
            [m_delegate showView:@"MailComposeView"];
            return;
        case SHOW:
            break;
    }

    [m_delegate showView:@"FunctionButtonView"];
}

- (id)initWithDelegate:(id<ControllerProtocol>) d detailType:(DetailType) detailType details:(id) details
{
    [super initWithStyle:UITableViewStyleGrouped delegate:d];
    m_detailType = detailType;
    m_details = [details retain];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* rightButtonTitle = nil;
    BOOL addDoneButton = NO;
    
    switch (m_detailType) {
        case SHOW:
            self.title = @"Program Info";
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            addDoneButton = YES;
            self.editing = NO;
            break;
        case STORE:
            self.title = @"Describe Program";
            rightButtonTitle = @"Send";
            addDoneButton = YES;
            self.editing = YES;
            break;
        case LOAD:
            self.title = @"";
            self.editing = NO;
            self.tableView.allowsSelection = NO;
            rightButtonTitle = @"Load";
            break;
        case ADD:
            self.title = @"";
            self.editing = NO;
            self.tableView.allowsSelection = NO;
            rightButtonTitle = @"Add";
            break;
    }
    
    if (rightButtonTitle)
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(rightButton)] autorelease];

    if (addDoneButton)
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
            initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)] autorelease];

	self.tableView.allowsSelectionDuringEditing = YES;
}

// TableView datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"MyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kCellIdentifier] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

	switch (indexPath.row) {
        case 0: 
			cell.textLabel.text = @"Title";
			cell.detailTextLabel.text = [m_details valueForKey:@"title"];
			break;
        case 1: 
			cell.textLabel.text = @"Category";
			cell.detailTextLabel.text = [m_details valueForKey:@"category"];
			break;
        case 2:
			cell.textLabel.text = @"Description";
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			cell.detailTextLabel.text = [m_details valueForKey:@"description"];
			break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (indexPath.row != 2)
        return 40;
        
    NSString *str = [m_details valueForKey:@"description"];
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    CGSize withinsize = CGSizeMake(190, 5000);
    CGSize sz = [str sizeWithFont:font constrainedToSize:withinsize lineBreakMode:UILineBreakModeWordWrap];
    return MAX(40, sz.height + 20);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing)
        self.navigationItem.rightBarButtonItem = nil;
    [super setEditing:editing animated:animated];
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.editing) ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.editing)
        return;
        
    NSString* title;
    NSString* key;
    switch (indexPath.row) {
        case 0: title = @"Title"; key = @"title"; break;
        case 1: title = @"Category"; key = @"category"; break;
        case 2: title = @"Description"; key = @"description"; break;
    }

    EditViewController *controller = [[EditViewController alloc] initWithKey:key delegate:m_delegate];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    controller.title = title;
    
	[controller release];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
        [self.tableView reloadData];
}

@end
