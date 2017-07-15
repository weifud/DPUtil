//
//  DPTcpSocket.h
//  DPRing
//
//  Created by weifu Deng on 3/7/16.
//  Copyright © 2016 Digital Power. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>

@interface DPTimevl: NSObject
@property (nonatomic, assign) __darwin_time_t tv_sec;       /* seconds (long) */
@property (nonatomic, assign) __darwin_suseconds_t tv_usec; /* microseconds (int) */
@end


@interface DPTcpSocket : NSObject

/**
 *  @brief  native socket handler
 */
@property (nonatomic, assign, readonly) int iSock;

/**
 *  @brief  连接超时
 */
@property (nonatomic, retain) DPTimevl *tvConncet;

/**
 *  @brief  接收信息超时
 */
@property (nonatomic, retain) DPTimevl *tvRecv;

/**
 *  @brief  是否连接
 */
@property (nonatomic, assign, readonly) BOOL bConnect;

/**
 *  @brief  是否启用后台voip
 */
@property (nonatomic, assign) BOOL bBGVoip;

/**
 *  @brief  连接目标ip
 *
 *  @param ip   ip地址
 *  @param port 端口
 *
 *  @return YES/NO (成功/失败)
 */
- (BOOL)DPTcpConnectWithIntIP:(int32_t)ip Port:(int32_t)port;

/**
 *  @brief  连接目标域名
 *
 *  @param hostNstr 域名
 *  @param iPort   端口
 *
 *  @return YES/NO (成功/失败)
 */
- (BOOL)DPTcpConnectWithHostName:(NSString*)hostNstr Port:(int32_t)iPort;

/**
 *  @brief  断开连接
 */
- (void)DPTcpDisconnect;

/**
 *  @brief  读取数据
 *
 *  @param pData 数据缓冲区
 *  @param iLen  数据大小
 *
 *  @return 
 *          0: 超时或者iLen <= 0;
 *         -1: 错误;
 *         -2: 远程关闭;
 *      other: 实际接收数据的长度;
 */
- (int)DPTcpReadData:(char*)pData LenOfData:(int)iLen;

/**
 *  @brief  发送数据
 *
 *  @param pData 数据缓冲区
 *  @param iLen  数据大小
 *
 *  @return 实际发送数据的长度
 */
- (int)DPTcpWriteData:(char*)pData LenOfData:(int)iLen;

@end
