//
//  BRAddedFriendTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRAddedFriendTableViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRAddedFriendTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *userMessage;

@end

@implementation BRAddedFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationBarItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Add save and cancel buttons to navigation bar
- (void)setUpNavigationBarItem {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStylePlain target:self action:@selector(sendBtn)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtn)];
}



/**
    添加好友，如果已经是好友 则直接返回，不是好友 则发送好友请求
 */
- (void)sendBtn {
    [self.view endEditing:YES];
    
    NSArray *contactArray = [[EMClient sharedClient].contactManager getContacts];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([contactArray containsObject:self.userID]) {
        hud.label.text = @"Already your friend.";
    } else {
        EMError *error = [[EMClient sharedClient].contactManager addContact:self.userID message: self.userMessage.text];
        hud.mode = MBProgressHUDModeText;
        if (error) {
            hud.label.text = error.errorDescription;
            
        } else {
            hud.label.text = @"Send Successfully";
            
        }
    }
    [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end