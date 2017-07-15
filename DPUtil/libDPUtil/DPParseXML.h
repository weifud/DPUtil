//
//  DPParseXML.h
//  DPCloud
//
//  Created by weifu Deng on 6/26/15.
//  Copyright (c) 2015 digital power. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPParseXML : NSObject

/**
 *  @brief  获取xml字符串指定节点值
 *          遇\0结束, 不可用来获取含有\0数据
 *
 *  @param pXml  (In)xml字符串
 *  @param pName (In)节点名称
 *
 *  @return 指定节点值
 */
+ (nullable char *)DPGetNodeValueXml:(nonnull char *)pXml NodeName:(nonnull char *)pName;

/**
 *  @brief  获取xml字符串的下一个节点值
 *          遇\0结束, 不可用来获取含有\0数据
 *
 *  @param pXml   (In)xml字符串
 *  @param pName  (Out)节点名称
 *  @param len    (In)节点名称最大长度
 *  @param offset (Out)偏移量
 *
 *  @return xml字符串的下一个节点值
 */
+ (nullable char *)DPGetNextNodeValueXml:(nonnull char *)pXml NodeName:(nonnull char *)pName MaxLenOfNode:(NSInteger)len Offset:(nonnull NSInteger *)offset;

/**
 *  @brief  获取xml字符串指定节点数据
 *
 *  @param pXml     (In)xml字符串
 *  @param len      (In)xml字符串长度
 *  @param nstrName (In)节点名称
 *
 *  @return xml字符串指定节点数据
 */
+ (nullable NSData *)DPGetNodeDataXml:(nonnull char *)pXml LenofData:(NSInteger)len NodeName:(nonnull NSString *)nstrName;

@end
