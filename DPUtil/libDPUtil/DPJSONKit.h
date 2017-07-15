//
//  DPJSONKit.h
//  DPUtil
//
//  Created by weifu Deng on 4/6/16.
//  Copyright © 2016 Digital Power. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPJSONKit : NSObject

/**
 *  @brief  创建JSON字符串
 *
 *  @param cmdDic OC字典
 *
 *  @return JSON字符串数据
 */
+ (nullable NSData *)DPCreatCmdJsonStr:(nonnull NSDictionary *)cmdDic;

/**
 *  @brief  解析JSON字符串
 *
 *  @param pStr JSON字符串
 *  @param ilen JSON字符串长度
 *
 *  @return OC字典
 */
+ (nullable id)DPParseJSONStr:(nonnull char *)pStr lenOfStr:(unsigned int)ilen;

/**
 *  @brief  解析JSON字符串
 *
 *  @param jsonNstr JSON字符串
 *
 *  @return OC字典
 */
+ (nullable id)DPParseJSONStr2:(nonnull NSString *)jsonNstr;

@end
