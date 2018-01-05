//
//  CreateChatViewController.h
//  LinC
//
//  Created by Yingwei Fan on 6/16/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRCreateChatViewController : UITableViewController
@property (nonatomic, strong) void (^dismissCompletionBlock)(UIViewController *);
@property (nonatomic, assign) BOOL doesAddMembers;
@property (nonatomic, strong) NSArray *groupMembersArray;
@property (nonatomic, strong) NSString *groupID;
@end
