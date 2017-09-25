//
//  BRFriendRequestTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/22/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendRequestTableViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRClientManager.h"
#import "BRFileWithNewFriendsRequestData.h"
#import <MBProgressHUD.h>
#import <SAMKeychain.h>

@interface BRFriendRequestTableViewController ()

// User Info labels
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userWhatUp;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation BRFriendRequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageLabel.text = self.message;
    self.userID.text = self.searchID;
    [self loadDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
    从服务器获取好友JSON信息，并赋值到各个label上
 */
- (void)loadDataFromServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefault objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account: savedUserName];
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/users/find"];
    NSDictionary *parameters = @{@"key":@"username", @"value":self.searchID};
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        [self setUpUserInfoFrom:responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

// set up all data to user labels
- (void)setUpUserInfoFrom:(id)responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"dict--%@", dict);
        if ([dict[@"status"]  isEqual: @"success"]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSArray *userArray = [dict[@"data"][@"users"] lastObject];
            NSDictionary *userDict = (NSDictionary *)userArray;
            self.userID.text = userDict[@"username"];
        }
    }
}

#pragma mark - UITableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}


/**
    同意好友请求, 并删除好友请求数据
 */
- (IBAction)agreeBtn {
    [BRFileWithNewFriendsRequestData deleteNewFriendRequest:self.searchID];
    [[EMClient sharedClient].contactManager acceptInvitationForUsername:self.searchID];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/**
    拒绝添加好友，并删除好友请求数据
 */
- (IBAction)refuseBtn {
    [BRFileWithNewFriendsRequestData deleteNewFriendRequest:self.searchID];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end