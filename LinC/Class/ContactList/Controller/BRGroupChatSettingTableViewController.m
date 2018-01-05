//
//  BRGroupChatSettingTableViewController.m
//  LinC
//
//  Created by zhe wu on 12/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRGroupChatSettingTableViewController.h"
#import "BRGroupMemberTableViewCell.h"
#import "BRClientManager.h"
#import "BRQRCodeViewController.h"
#import "BRRequestMessageTableViewController.h"
#import <MBProgressHUD.h>
#import <Hyphenate/Hyphenate.h>
#import "BRContactListModel.h"
#import "BRFriendInfoTableViewController.h"
#import "BRCoreDataManager.h"
#import "BRCreateChatViewController.h"
#import "BRMessageViewController.h"
#import "BRNavigationController.h"
#import "BRContactListViewController.h"

@interface BRGroupChatSettingTableViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *hud;
    NSString *groupOwner;
    EMGroupOptions *groupSetting;
    NSArray *groupMembersName;
    EMGroup *currentGroup;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *copiedGroupIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupIDLabel;
@property (weak, nonatomic) IBOutlet UIView *leaveGroupView;



@end

@implementation BRGroupChatSettingTableViewController

typedef enum : NSInteger {
    TableViewGroupSetting = 0,
    TableViewGroupMembers,
} TableViewSession;

typedef enum : NSInteger {
    TableViewGroupID = 0,
    TableViewGroupName,
    TableViewGroupQRCode,
    TableViewGroupDescription,
} TableViewRow;

// Tableview cell identifier
static NSString * const cellIdentifier = @"groupCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTableView];
    [self setUpNavigationRightItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpGroupInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpGroupInfo {
    // 获取群信息
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            currentGroup = aGroup;
            self.groupNameLabel.text = aGroup.subject;
            self.groupIDLabel.text = aGroup.groupId;
            groupOwner = aGroup.owner;
            groupSetting = aGroup.setting;
            groupMembersName = aGroup.occupants;
            if (self.groupIDLabel.text.length != 0) {
                self.copiedGroupIDLabel.hidden = NO;
            }
            if (aGroup.description.length == 0) {
                self.groupDescriptionLabel.text = @"None";
            } else {
                self.groupDescriptionLabel.text = aGroup.description;
            }
            [self.groupDescriptionLabel sizeToFit];
            
            // 群主 或 群设置不是EMGroupStylePrivateOnlyOwnerInvite时， 允许加新组员
            if ([aGroup.owner isEqualToString:[EMClient sharedClient].currentUsername] || aGroup.setting.style != EMGroupStylePrivateOnlyOwnerInvite) {
                [self setUpNavigationRightItem];
            }
            
            [[BRClientManager sharedManager] getUserInfoWithUsernames:aGroup.occupants andSaveFlag:NO success:^(NSMutableArray *groupMembersArray) {
                self.dataArray = groupMembersArray;
                [self.tableView reloadData];
            } failure:^(EMError *error) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = error.description;
                [hud hideAnimated:YES afterDelay:1.5];
            }];
        } else {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = aError.errorDescription;
            hud.label.numberOfLines = 0;
            [self performSelector:@selector(dismissVie) withObject:nil afterDelay:1.5];
        }
    }];
    
    [self.copiedGroupIDLabel setTitle:@"Copy" forState:UIControlStateNormal];
    [self.copiedGroupIDLabel setTitle:@"Copied" forState:UIControlStateSelected];
    [self.copiedGroupIDLabel addTarget:self action:@selector(copyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.doesJoinGroup) {
        self.leaveGroupView.hidden = YES;
    } else {
        self.leaveGroupView.hidden = NO;
    }
}

- (void)setUpTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 90;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRGroupMemberTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
}

- (void)copyBtnClicked:(UIButton *)copyBtn {
    copyBtn.selected = !copyBtn.selected;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.groupIDLabel.text;
}

- (void)setUpNavigationRightItem {
    
    [self.navigationController setNavigationBarHidden: NO];
    if (self.doesJoinGroup) {
        // 请求加群
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(clickJoinGroup)];
    } else {
       // 查看群设置
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 35, 35)];
        [btn setBackgroundImage:[UIImage imageNamed:@"add_setting"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"add_setting_highlighted"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(clickAddMoreMembers) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}

/**
 点击请求加群按钮
 */
- (void)clickJoinGroup {

    switch (groupSetting.style) {
        case EMGroupStylePrivateOnlyOwnerInvite:
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Only host invite to join";
            [hud hideAnimated:YES afterDelay:1.5];
            break;
        case EMGroupStylePrivateMemberCanInvite:
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Only members invite to join";
            [hud hideAnimated:YES afterDelay:1.5];
            break;
        case EMGroupStylePublicJoinNeedApproval:
            [self sendInviteMessage];
            break;
        case EMGroupStylePublicOpenJoin:
            [self joinGroupAutomatically];
            break;
        default:
            break;
    }
    
}

- (void)sendInviteMessage {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRRequestMessageTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRRequestMessageTableViewController"];
    vc.searchID = groupOwner;
    vc.doesJoinGroup = YES;
    vc.groupID = self.groupID;
    [self.navigationController pushViewController:vc animated:YES];
}


/**
    邀请更多好友加群
 */
- (void)clickAddMoreMembers {
    BRCreateChatViewController *vc = [[BRCreateChatViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.doesAddMembers = YES;
    vc.groupID = self.groupID;
    vc.groupMembersArray = groupMembersName;
    [self.navigationController pushViewController:vc animated:YES];
 }


- (void)joinGroupAutomatically {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[EMClient sharedClient].groupManager joinPublicGroup:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Join Successfully";
            [self performSelector:@selector(pushToGroupMessageBy:) withObject:aGroup afterDelay:1.5];
            
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = aError.errorDescription;
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

- (void)pushToGroupMessageBy:(EMGroup *)group {
    [hud hideAnimated:YES];
    BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:group.groupId conversationType:EMConversationTypeGroupChat];
    vc.title = group.subject;
    vc.hidesBottomBarWhenPushed = YES;
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    NSMutableArray *deleteArr = [NSMutableArray array];
    for (int i = 0; i < vcArray.count; i++) {
        UIViewController *vc = [vcArray objectAtIndex:i];
        if (![vc isKindOfClass:[BRContactListViewController class]]) {
            [deleteArr addObject:vc];
        }
    }
    [vcArray removeObjectsInArray:deleteArr];
    [vcArray addObject:vc];
    [self.navigationController setViewControllers:vcArray animated:YES];
}

/**
 退出群聊
 */
- (IBAction)leaveGroupBtnClicked {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
     UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *delete = nil;
    if ([username isEqualToString: groupOwner]) {
        // 群主解散群
        delete = [UIAlertAction actionWithTitle:@"Destory group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[EMClient sharedClient].groupManager destroyGroup:self.groupID finishCompletion:^(EMError *aError) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                if (!aError) {
                    hud.label.text = @"Destory group successfully.";
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                } else {
                    hud.label.text = aError.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }];
    } else {
        // 群成员退出群
        delete = [UIAlertAction actionWithTitle:@"Comfirm leave group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[EMClient sharedClient].groupManager leaveGroup:self.groupID completion:^(EMError *aError) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                if (!aError) {
                    hud.label.text = @"Leave group successfully.";
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                } else {
                    hud.label.text = aError.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        self.tableView.editing = NO;
    }];
    
    [actionSheet addAction:delete];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)dismissVie {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableViewGroupSetting) {
        return [super tableView:tableView numberOfRowsInSection: section];
    } else {
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == TableViewGroupSetting) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        BRGroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        //        cell.textLabel.text = self.dataArray[indexPath.row];
        cell.model = self.dataArray[indexPath.row];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupSetting && indexPath.row == TableViewGroupDescription ) {
        return UITableViewAutomaticDimension;
    } else {
        return 50;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupMembers) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewGroupSetting]];
    }else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupSetting && indexPath.row == TableViewGroupQRCode) {
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];
        BRQRCodeViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRQRCodeViewController"];
        //拼接group字符串，以group结尾的二维码为群二维码
        vc.username = [self.groupID stringByAppendingString:@"group"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == TableViewGroupMembers) {
        // 查看群成员信息
        BRContactListModel *model = self.dataArray[indexPath.row];
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
        vc.group = currentGroup;
        if ([username isEqualToString:model.username]) {
            
            vc.isSelf = YES;
            vc.contactListModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy: model.username];
            
            if (friendInfo) {
                vc.isFriend = YES;
            }
            vc.contactListModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == TableViewGroupMembers) {
        return 60;
    } else {
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

@end