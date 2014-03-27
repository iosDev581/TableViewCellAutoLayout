//
//  RJTableViewController.m
//  TableViewController
//
//  Created by Kevin Muldoon & Tyler Fox on 10/5/13.
//  Copyright (c) 2013 RobotJackalope. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RJTableViewController.h"
#import "RJModel.h"
#import "RJTableViewCell.h"

static NSString *CellIdentifier = @"RJTableViewCell";

@interface RJTableViewController ()

@property (strong, nonatomic) RJModel *model;

// A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
// handle the height calculations. These are never drawn onscreen. The dictionary is in the format:
//      { NSString *reuseIdentifier : UITableViewCell *offscreenCell, ... }
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

// For iOS 7.0.x compatibility ONLY (this bug is fixed in iOS 7.1):
// This property is used to work around the constraint exception that is thrown if the
// estimated row height for an inserted row is greater than the actual height for that row.
// See: https://github.com/caoimghgin/TableViewCellWithAutoLayout/issues/6
@property (assign, nonatomic) BOOL isInsertingRow;

@property (strong, nonatomic) RJTableViewCell *templateCell;

@end

@implementation RJTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.model = [[RJModel alloc] init];
        [self.model populateDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Auto Layout Table View";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRow:)];
    
    self.tableView.allowsSelection = NO;

    [self.tableView registerClass:[RJTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RJTableViewCell class])];
    RJTableViewCell *cell = [[RJTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    self.templateCell = cell;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

// This method is called when the Dynamic Type user setting changes (from the system Settings app)
- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)clear:(id)sender
{
    NSMutableArray *rowsToDelete = [NSMutableArray new];
    for (NSUInteger i = 0; i < [self.model.dataSource count]; i++) {
        [rowsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    self.model = [[RJModel alloc] init];
    
    [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView reloadData];
}

- (void)addRow:(id)sender
{
    [self.model addSingleItemToDataSource];
    
    self.isInsertingRow = YES;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.model.dataSource count] - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.isInsertingRow = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.model.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell for this indexPath
    NSDictionary *dataSourceItem = [self.model.dataSource objectAtIndex:indexPath.row];
    [cell configWithData:[dataSourceItem valueForKey:@"title"]];

    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataSourceItem = [self.model.dataSource objectAtIndex:indexPath.row];
    [self.templateCell configWithData:[dataSourceItem valueForKey:@"title"]];

    // force layout
    [self.templateCell setNeedsLayout];
    [self.templateCell layoutIfNeeded];
    CGFloat height = [self.templateCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    height += 1;
    return height;
}

@end
