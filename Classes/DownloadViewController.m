//
//  DownloadViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "DownloadViewController.h"

#import "DetailViewController.h"

@implementation DownloadViewController

- (void)loadProgramList
{
    [m_programList release];
    [m_directory release];
    m_directory = nil;
    
    m_programList = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:@"http://marrin.com/MrScience/programList.plist"]];
    [m_programList retain];
    
    NSMutableDictionary* categoryDictionary = [NSMutableDictionary dictionary];
    
    // Create a dictionary with categories as keys containing an array of all the titles in that category
    for (NSDictionary* program in m_programList) {
        NSString* category = [program objectForKey:@"category"];
        NSString* title = [program objectForKey:@"title"];
        if (!category || ![category length] || !title || ![title length])
            continue;
            
        NSMutableArray* array = [categoryDictionary objectForKey:category];
        if (!array) {
            array = [NSMutableArray array];
            [categoryDictionary setObject: array forKey:category];
        }
        
        [array addObject:title];
    }
    
    // Create a directory array of sorted categories and title arrays
    NSArray* sortedCategories = [[categoryDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray* directory = [[NSMutableArray alloc] init];
    m_directory = directory;
    
    for (NSString* category in sortedCategories)
        [directory addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            category, @"category",
            [categoryDictionary objectForKey:category], @"array",
            nil]];
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    [super initWithStyle:UITableViewStyleGrouped delegate:d];
    [self loadProgramList];
    return self;
}

- (IBAction)add
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Download";
    //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)] autorelease];
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
    }
    
    cell.textLabel.text = [[[m_directory objectAtIndex:indexPath.section] objectForKey:@"array"] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[m_directory objectAtIndex:section] objectForKey:@"array"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [m_directory count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[m_directory objectAtIndex:section] objectForKey:@"category"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString* category = [m_delegate.calculator.category length] ? m_delegate.calculator.category : @"Uncategorized";
    if ([[[m_directory objectAtIndex:section] objectForKey:@"category"] isEqualToString:category])
        return @"Currently loaded program is in blue";
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* category = [[m_directory objectAtIndex:indexPath.section] objectForKey:@"category"];
    NSString* title = [[[m_directory objectAtIndex:indexPath.section] objectForKey:@"array"] objectAtIndex:indexPath.row];
    
    NSDictionary* details;
    for (details in m_programList)
        if ([[details objectForKey:@"category"] isEqualToString:category] && [[details objectForKey:@"title"] isEqualToString:title])
            break;
    
    DetailViewController *controller = [[DetailViewController alloc] initWithDelegate:m_delegate detailType:ADD details:details];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
