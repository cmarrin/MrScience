//
//  LoadViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ListViewController.h"

#import "DetailViewController.h"
#import "DownloadViewController.h"

@implementation ListViewController

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    [super initWithStyle:UITableViewStyleGrouped delegate:d];
    
    m_list = [[Calculator programList] retain];   
    return self;
}

- (IBAction)cancel
{
    [m_delegate showView:@"FunctionButtonView"];
}

- (IBAction)add
{
    DownloadViewController *controller = [[DownloadViewController alloc] initWithDelegate:m_delegate];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Load Program";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)] autorelease];
}

- (void)dealloc {
    [super dealloc];
}

// TableView datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"MyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[[m_list objectAtIndex:indexPath.section] objectForKey:@"array"] objectAtIndex:indexPath.row];

    NSString* category = [m_delegate.calculator.category length] ? m_delegate.calculator.category : @"Uncategorized";

    BOOL current = [[[m_list objectAtIndex:indexPath.section] objectForKey:@"category"] isEqualToString:category] &&
                   [cell.textLabel.text isEqualToString:m_delegate.calculator.title];
    cell.textLabel.textColor = current ? [UIColor blueColor] : [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[m_list objectAtIndex:section] objectForKey:@"array"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [m_list count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[m_list objectAtIndex:section] objectForKey:@"category"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString* category = [m_delegate.calculator.category length] ? m_delegate.calculator.category : @"Uncategorized";
    if ([[[m_list objectAtIndex:section] objectForKey:@"category"] isEqualToString:category])
        return @"Currently loaded program is in blue";
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* category = [[m_list objectAtIndex:indexPath.section] objectForKey:@"category"];
    NSString* title = [[[m_list objectAtIndex:indexPath.section] objectForKey:@"array"] objectAtIndex:indexPath.row];
    
    DetailViewController *controller = [[DetailViewController alloc] initWithDelegate:m_delegate detailType:LOAD details:[Calculator detailsForProgram:title withCategory:category]];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
