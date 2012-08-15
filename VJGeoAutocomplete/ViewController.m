//
//  ViewController.m
//  VJGeoAutocomplete
//
//  Created by Vashishtha Jogi on 8/14/12.
//  Copyright (c) 2012 vashishthajogi.com. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+CancelableBlock.h"
#import "VJGeoAutocomplete.h"

@interface ViewController ()

@property(strong, nonatomic) NSMutableArray *dataSource;

- (void)autocompleteWithText:(NSString *)text;

@end

@implementation ViewController
@synthesize dataSource=_dataSource;

- (NSMutableArray *)dataSource {
    if (_dataSource==nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AutocompleteCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.detailTextLabel.text = [[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"subtitle"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search bar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self autocompleteWithText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [self autocompleteWithText:searchBar.text];
}

#pragma mark - private methods

- (void)autocompleteWithText:(NSString *)text {
    [self performBlock:^{
        [VJGeoAutocomplete autocomplete:text completion:^(NSArray *predictions, NSError *error) {
            [self.dataSource removeAllObjects];
            for (VJGeoPrediction *prediction in predictions) {
                [self.dataSource addObject:@{@"title" : prediction.titleForTableViewCell,
                 @"subtitle": prediction.subtitleForTableViewCell}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
    } afterDelay:1.0 cancelPreviousRequest:YES];
}


@end
