//
//  NotbookChooserViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 2/11/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "NotebookChooserViewController.h"
#import "EvernoteSDK.h"

@interface NotbookChooserViewControllerCell : UITableViewCell

@property(nonatomic, strong) EDAMNotebook *notebook;

@end

@interface NotebookChooserViewController ()

@property(nonatomic, strong) NSArray *notebooks;

- (IBAction)accept:(id)sender;

@end

@implementation NotebookChooserViewController

- (void)setSelectedNotebookWithGUID:(NSString *)notebookGUID
{
    if(notebookGUID) {
        [[EvernoteNoteStore noteStore] getNotebookWithGuid:notebookGUID success:^(EDAMNotebook *notebook) {
            self.selectedNotebook = notebook;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            ;
        }];
    }
    else {
        [[EvernoteNoteStore noteStore] getDefaultNotebookWithSuccess:^(EDAMNotebook *notebook) {
            self.selectedNotebook = notebook;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            ;
        }];
    }
}

- (void)setSelectedNotebookWithName:(NSString *)notebookName
{
    [[EvernoteNoteStore noteStore] listNotebooksWithSuccess:^(NSArray *notebooks) {
        for (EDAMNotebook* notebook in notebooks) {
            if([notebook.name isEqualToString:notebookName]) {
                self.selectedNotebook = notebook;
                return;
            }
        };
    } failure:^(NSError *error) {
        ;
    }];
}

- (IBAction)accept:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(notebookChooserController:didSelectNotebook:)])
            [self.delegate notebookChooserController:self didSelectNotebook:self.selectedNotebook];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[NotbookChooserViewControllerCell class] forCellReuseIdentifier:@"NotbookChooserViewControllerCell"];
    self.navigationItem.hidesBackButton = YES;
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(accept:)];
    }
    [[EvernoteNoteStore noteStore] listNotebooksWithSuccess:^(NSArray *notebooks) {
        NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.notebooks = [notebooks sortedArrayUsingDescriptors:@[sortDesc]];
        [self.tableView reloadData];
        if(self.selectedNotebook == nil) {
            [self setSelectedNotebookWithGUID:nil];
        }
        else {
            [self setSelectedNotebook:self.selectedNotebook];
        }
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notebooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"NotbookChooserViewControllerCell";
    NotbookChooserViewControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NotbookChooserViewControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    EDAMNotebook *notebook = (self.notebooks)[indexPath.row];
    [cell setNotebook:notebook];
    if ([self.selectedNotebook.guid isEqualToString:notebook.guid]) {
        self.selectedIndex = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self numberOfSectionsInTableView:tableView] == (section + 1)) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedNotebook = (self.notebooks)[indexPath.row];
    
    [self.tableView reloadData];
}

@end

@implementation NotbookChooserViewControllerCell

- (void)setNotebook:(EDAMNotebook *)notebook
{
    _notebook = notebook;
    self.textLabel.text = [notebook name];
}

@end

