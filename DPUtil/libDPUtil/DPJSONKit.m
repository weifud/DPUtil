//
//  DPJSONKit.m
//  DPUtil
//
//  Created by weifu Deng on 4/6/16.
//  Copyright © 2016 Digital Power. All rights reserved.
//

#import "DPJSONKit.h"

@implementation DPJSONKit

+ (NSData *)DPCreatCmdJsonStr:(NSDictionary *)cmdDic{
    NSData *pData = nil;
    if ([NSJSONSerialization isValidJSONObject:cmdDic]) {
        NSError *err = nil;
        pData = [NSJSONSerialization dataWithJSONObject:cmdDic
                                                options:0
                                                  error:&err];
        if (!pData) {
            NSLog(@"creatCmdJsonStr err: %@", err.localizedDescription);
        }
    }
    else{
        NSLog(@"creatCmdJsonStr err: json object isn't valid");
    }
    
    return pData;
}

+ (id)DPParseJSONStr:(char *)pStr lenOfStr:(unsigned int)ilen{
    NSString *jsonNstr = [[NSString alloc] initWithBytes:pStr
                                                  length:ilen
                                                encoding:NSUTF8StringEncoding];
    NSData *jsonData = [jsonNstr dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        NSLog(@"parse json str err: json data is nil");
        return NULL;
    }
    
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    [jsonNstr release];
    
    if (!dic) {
        NSLog(@"parse json str err: %@", err.localizedDescription);
        return nil;
    }
    else{
        return dic;
    }
}

+ (id)DPParseJSONStr2:(NSString *)jsonNstr{
    NSData *jsonData = [jsonNstr dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        NSLog(@"parse json str err: json data is nil");
        return NULL;
    }
    
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (!dic) {
        NSLog(@"parse json str err: %@", err.localizedDescription);
        return nil;
    }
    else{
        return dic;
    }
}

@end
