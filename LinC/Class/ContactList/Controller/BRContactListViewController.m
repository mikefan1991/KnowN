//
//  BRRefreshViewController.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRContactListViewController.h"
#import "BRContactListTableViewCell.h"
#import "IUserModel.h"
#import "BRAddingFriendViewController.h"
#import "BRMessageViewController.h"
#import "BRClientManager.h"
#import <MJRefresh.h>


@interface BRContactListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *storedListArray;
@property (nonatomic, strong) NSArray *storedIconArray;

@end

@implementation BRContactListViewController

typedef enum : NSInteger {
    TableViewSectionZero = 0,
    TableViewSectionOne,
} TableViewSession;

typedef enum : NSInteger {
    TableViewNewFriend = 0,
    TableVIewGroup,
} UITableViewRow;

// Tableview cell identifier
static NSString * const cellIdentifier = @"ContactListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpTableView];
    [self setUpNavigationBarItem];
    
    [self tableViewDidTriggerHeaderRefresh];
}


/**
 *  Lazy load NSArray storedListArray
 *
 *  @return _storedListArray
 */
- (NSArray *)storedListArray
{
    if (!_storedListArray) {
        _storedListArray = [NSArray array];
    }
    return _storedListArray;
}

/**
 *  Lazy load NSArray storedIconArray
 *
 *  @return _storedIconArray
 */
- (NSArray *)storedIconArray {
    if (_storedIconArray == nil) {
        _storedIconArray = [NSArray array];
    }
    return _storedIconArray;
}

//// Load all friends model 
//- (void)loadData {
//    self.dataArray = [[[EMClient sharedClient].contactManager getContacts] copy];
//    NSLog(@"%@", self.dataArray);
//}

/**
 * Set up tableView
 */
- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Register reuseable tableview cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRContactListTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.storedListArray = @[@"New Friend", @"Group"];
    self.storedIconArray = @[[UIImage imageNamed:@"new_friend_request"], [UIImage imageNamed:@"owned_group"]];
}

- (void)setUpNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_new_friend"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_new_friend_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickAddNewFriend) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - button action
-(void)clickAddNewFriend {
//    BRAddingContentView *cView = [[[NSBundle mainBundle] loadNibNamed:@"BRAddingContentView" owner:self options:nil] firstObject];
//    cView.frame = CGRectMake(50, 50, 200, 200);
//    cView.backgroundColor = [UIColor redColor];
//    [self.view addSubview: cView];
    
    BRAddingFriendViewController *vc = [[BRAddingFriendViewController alloc] initWithNibName:@"BRAddingFriendViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    if (section == TableViewSectionZero ) {
        return self.storedListArray.count;
    } else {
        return self.dataArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == TableViewSectionZero) {
        BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell.nickName.text = self.storedListArray[indexPath.row];
        cell.imageIcon.image = self.storedIconArray[indexPath.row];
        return cell;
    } else {
    
        BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
        id<IUserModel> contactListModel = [self.dataArray objectAtIndex:indexPath.row];
        cell.contactListModel = contactListModel;
    
        return cell;
    }
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

/**
 * Set up white space between groups
 */
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // New friend and group session
    if (indexPath.section == TableViewSectionZero) {
        if (indexPath.row == TableVIewGroup) {
            
        }
        if (indexPath.row == TableViewNewFriend) {
            
        }
    }
    // User contact list cell
    if (indexPath.section == TableViewSectionOne) {
        BRContactListModel *contactListModel = self.dataArray[indexPath.row];
    }
}


- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error) {
            NSMutableArray *contactsSource = [NSMutableArray arrayWithArray:buddyList];
            NSMutableArray *tempDataArray = [NSMutableArray array];
            
            // remove the contact that is currently in the black list
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
            for (NSInteger i = 0; i < buddyList.count; i++) {
                NSString *buddy = [buddyList objectAtIndex:i];
                if (![blockList containsObject:buddy]) {
                    [contactsSource addObject:buddy];
                    
                    BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:buddy];
                    
                    if(model){
                        [tempDataArray addObject:model];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray removeAllObjects];
                [weakself.dataArray addObjectsFromArray:tempDataArray];
                [weakself.tableView reloadData];
            });
        }
        [weakself tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
    });
}

@end
