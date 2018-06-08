//
//  BRFileWithNewFriendsRequestData.m
//  KnowN
//
//  Created by zhe wu on 9/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFileWithNewRequestData.h"

@implementation BRFileWithNewRequestData

/**
    获取到ios document 文件目录
 
 @return document path
 */
+ (NSString *)getPathWithFileName:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent: file];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create new file if not exist
    if (![fileManager fileExistsAtPath: path]) {
        path = [documentsDirectory stringByAppendingPathComponent: file];
    }
    return path;
}

/**
 保存新的请求数据到plist文件

 @param fileName 需要保存的信息文件名(好友或群)
 @param dictData 申请信息字典数据
 @return YES 保存成功，NO 申请已经存在，不保存
 */
+ (BOOL)savedToFileName:(NSString *)fileName withData:(NSDictionary *)dictData
{
    NSString *path = [self getPathWithFileName:fileName];

    // Write data to file
    NSMutableArray *newRequestData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    if (newRequestData == nil) {
        newRequestData = [NSMutableArray array];
    }

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    if ([dictData[@"loginUser"] isEqualToString:username]) {
        for (NSUInteger i = 0; i < newRequestData.count; i++) {
            NSDictionary *dict = newRequestData[i];
            if ([dict[@"userID"] isEqualToString:dictData[@"userID"]]) {
                [newRequestData replaceObjectAtIndex:i withObject:dictData];
                [newRequestData writeToFile:path atomically:YES];
                return NO;
            }
        }
        [newRequestData addObject:dictData];
        [newRequestData writeToFile:path atomically:YES];
        return YES;
    }
    return NO;
}

/**
 读取文件，返回等待添加的好友数量
 
 @return NSString newfriendData.count
 */
+ (NSString *)countForNewRequestFromFile:(NSString *)fileName {
    NSString *path = [self getPathWithFileName:fileName];
    NSMutableArray *allRequestData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    NSMutableArray *requestData = [NSMutableArray array];
    for (int i = 0; i < allRequestData.count; i++) {
        if ([allRequestData[i][@"loginUser"] isEqualToString:username]) {
            [requestData addObject:allRequestData[i]];
        }
    }
    return [NSString stringWithFormat:@"%lu", (unsigned long)requestData.count];
}


/**
    获取到所有好友请求的数据

 @return NSMutableArray newfriendData
 */
+ (NSMutableArray *)getAllNewRequestDataFromFile:(NSString *)fileName {
    NSString *path = [self getPathWithFileName:fileName];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    NSMutableArray *allRequestData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    NSMutableArray *requestData = [NSMutableArray array];
    for (int i = 0; i < allRequestData.count; i++) {
        if ([allRequestData[i][@"loginUser"] isEqualToString:username]) {
            [requestData addObject:allRequestData[i]];
        }
    }
    if (!requestData) {
        requestData = [NSMutableArray array];
    }
    return requestData;
}


/**
    当点击接受或者拒绝按钮时，从好友请求数据中删除当前请求

 @param deleteID deleteID
 @return ture 删除成功， false 删除失败
 */
+ (BOOL)deleteRequestFromFile:(NSString *)fileName byID:(NSString *)deleteID {
    NSString *path = [self getPathWithFileName:fileName];
    NSMutableArray *newfriendData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    
    if (newfriendData) {
        for (int i = 0; i < newfriendData.count; i++) {
            NSDictionary *dict = [newfriendData objectAtIndex:i];
            if ([[dict allValues] containsObject:deleteID]) {
                [newfriendData removeObjectAtIndex:i];
                [newfriendData writeToFile:path atomically:YES];
                return true;
            }
        }
    }
    return false;
}



@end