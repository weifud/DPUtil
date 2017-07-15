//
//  DPAccountManager.m
//  DPCloud
//
//  Created by weifu Deng on 8/13/15.
//  Copyright (c) 2015 D-Power. All rights reserved.
//

#import "DPAccountManager.h"

#define kDPSecurityServiceName		@"DPAccountManager"
#define kDPCurrentAccount           @"CurrentAccount"
#define kDPHistoryAccountList		@"HistoryAccountList"

@implementation DPAccountManager
@synthesize serviceName;

- (id)init{
    self = [super init];
    if (self) {
        serviceName = kDPSecurityServiceName;
    }
    
    return self;
}

- (void)dealloc{
    [serviceName release];
    [super dealloc];
}

+ (DPAccountManager *)sharedInstance{
    static DPAccountManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

- (NSString *)DPGetCurrentAccount{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDPCurrentAccount];
}

- (NSArray*)DPGetHistoryAccountList{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDPHistoryAccountList];
}

- (void)DPRemoveHistoryAccount:(NSString*)account{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* historyAccountList = [defaults objectForKey:kDPHistoryAccountList];
    if(historyAccountList){
        NSMutableArray* newHistoryAccountList = [NSMutableArray arrayWithArray:historyAccountList];
        [newHistoryAccountList removeObject:account];
        [defaults setObject:newHistoryAccountList forKey:kDPHistoryAccountList];
        [defaults synchronize];
    }
}

- (NSString*)DPGetPassword:(NSString*)account{
    if(account){
        return [SFHFKeychainUtils getPasswordForUsername:account
                                          andServiceName:self.serviceName
                                                   error:nil];
    }
    
    return nil;
}

- (BOOL)DPSaveAccount:(NSString*)account Password:(NSString*)password{
    if(account && password){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSArray* historyAccountList = [defaults objectForKey:kDPHistoryAccountList];
        NSMutableArray* newHistoryAccountList = nil ;
        if(historyAccountList){
            newHistoryAccountList = [NSMutableArray arrayWithArray:historyAccountList];
            if([newHistoryAccountList indexOfObject:account] == NSNotFound ){
                [newHistoryAccountList addObject:account];
            }
        }
        else{
            newHistoryAccountList = [NSMutableArray arrayWithObject:account];
        }
        
        [defaults setObject:account forKey:kDPCurrentAccount];
        [defaults setObject:newHistoryAccountList forKey:kDPHistoryAccountList];
        [defaults synchronize];
        
        [SFHFKeychainUtils storeUsername:account
                             andPassword:password
                          forServiceName:self.serviceName
                          updateExisting:YES
                                   error:nil];
        return YES ;
    }
    
    return NO;
}

@end
