//
//  DPAccountManager.h
//  DPCloud
//
//  Created by weifu Deng on 8/13/15.
//  Copyright (c) 2015 D-Power. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFHFKeychainUtils.h"

@interface DPAccountManager : NSObject{
}

/**
 *  @brief  账号管理服务器标识(define: @"DPAccountManager")
 */
@property (nonatomic, retain) NSString *serviceName;


+ (DPAccountManager *)sharedInstance;

/**
 *  @brief  获取当前账号
 *
 *  @return 当前账号
 */
- (NSString *)DPGetCurrentAccount;

/**
 *  @brief  获取历史账号列表
 *
 *  @return 历史账号列表
 */
- (NSArray*)DPGetHistoryAccountList;

/**
 *  @brief  删除历史账号
 *
 *  @param account 要删除的账号
 */
- (void)DPRemoveHistoryAccount:(NSString*)account;

/**
 *  @brief  获取账号密码
 *
 *  @param account 账号
 *
 *  @return 账号密码
 */
- (NSString*)DPGetPassword:(NSString*)account;

/**
 *  @brief  保存账号和密码
 *
 *  @param account  账号
 *  @param password 密码
 *
 *  @return YES / NO （保存成功 / 保存失败）
 */
- (BOOL)DPSaveAccount:(NSString*)account Password:(NSString*)password;

@end
