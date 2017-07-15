//
//  DPSandBoxManager.h
//  SmartHome
//
//  Created by weifu Deng on 10/18/14.
//  Copyright (c) 2014 digital power. All rights reserved.
//

/*！
 * 默认情况下，每个沙盒含有3个文件夹：Documents, Library 和 tmp。因为应用的沙盒机制，应用只能在几个目录下读写文件
 * Documents：苹果建议将程序中建立的或在程序中浏览到的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录
 * Library：存储程序的默认设置或其它状态信息；
 * Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
 * tmp：提供一个即时创建临时文件的地方。
 
 * iTunes在与iPhone同步时，备份所有的Documents和Library文件。
 * iPhone在重启时，会丢弃所有的tmp文件。
 */

#import <Foundation/Foundation.h>

@interface DPSandBoxManager: NSObject

+ (DPSandBoxManager *)defaultManager;

/**
 *  @brief  获取Home目录路径
 *
 *  @return Home目录路径
 */
- (NSString *)DPSMGetHomeDir;

/**
 *  @brief  获取Document目录路径
 *
 *  @return Document目录路径
 */
- (NSString *)DPSMGetDocumentDir;

/**
 *  @brief  获取Cache目录路径
 *
 *  @return Cache目录路径
 */
- (NSString *)DPSMGetCacheDir;

/**
 *  @brief  获取Library目录路径
 *
 *  @return Library目录路径
 */
- (NSString *)DPSMGetLibraryDir;

/**
 *  @brief  获取Tmp目录路径
 *
 *  @return Tmp目录路径
 */
- (NSString *)DPSMGetTmpDir;

/**
 *  @brief  判断文件夹是否存在
 *
 *  @param dirPath 文件夹路径
 *
 *  @return YES / NO
 */
- (BOOL)DPSMIsDirExist:(NSString *)dirPath;

/**
 *  @brief  判断文件是否存在
 *
 *  @param filePath 文件路径
 *
 *  @return YES / NO
 */
- (BOOL)DPSMIsFileExist:(NSString *)filePath;

/**
 *  @brief  在指定路径下创建文件夹
 *
 *  @param path       指定路径
 *  @param newDirname 文件夹名称
 *
 *  @return YES / NO
 */
- (BOOL)DPSMCreatDirInPath:(NSString *)path NewDicName:(NSString *)newDirname;

/**
 *  @brief  在指定路径下创建文件并写入数据
 *
 *  @param path        指定路径
 *  @param newFileName 文件名
 *  @param pData       需要写入的数据
 *
 *  @return YES / NO
 */
- (BOOL)DPSMCreatFileInPath:(NSString *)path NewFileName:(NSString *)newFileName Data:(NSData *)pData;

/**
 *  @brief  获取指定路径一级子文件(夹)并保存到subArr
 *
 *  @param path   指定路径
 *  @param subArr [out]一级子文件(夹)数组
 */
- (void)DPSMGet1stLevSubFileInPath:(NSString *)path SubFileArr:(NSMutableArray *)subArr;

/**
 *  @brief  获取指定路径下的所有文件(包含该路径下所有子文件和文件夹)并保存到subArr
 *
 *  @param path   指定路径
 *  @param subArr [out]子文件数组 
 */
- (void)DPSMGetAllSubFileInPath:(NSString *)path SubFileArr:(NSMutableArray *)subArr;

/**
 *  @brief  删除文件(夹)
 *
 *  @param filePath 文件(夹)路径
 *
 *  @return YES / NO
 */
- (BOOL)DPSMDeleteFile:(NSString *)filePath;

/**
 *  @brief  删除文件夹下所有文档
 *
 *  @param dirPath 文件夹路径
 */
- (void)DPSMDeleteAllFileInDir:(NSString *)dirPath;

/**
 *  @brief  将数据写入文件
 *
 *  @param pData    Data数据
 *  @param filePath 文件路径
 *  @param bReplace 是否覆盖目标文件
 *
 *  @return YES / NO
 */
- (BOOL)DPSMWriteNewFile:(NSData *)pData FilePath:(NSString *)filePath Replace:(BOOL)bReplace;

/**
 *  @brief  将一段Data数据插入文件
 *
 *  @param pData    Data数据
 *  @param filePath 文件路径
 *  @param Offset   插入起始偏移量
 *
 *  @return YES / NO
 */
- (BOOL)DPSMWritetoFile:(NSData *)pData FilePath:(NSString *)filePath Offset:(int64_t)Offset;

/**
 *  @brief  读取文件的一段Data数据
 *
 *  @param filePath 文件路径
 *  @param len      要读取数据的长度
 *  @param offset   读取起始偏移量
 *
 *  @return Data数据
 */
- (NSData *)DPSMReadDataFromFile:(NSString *)filePath LenOfData:(NSInteger)len Offset:(int64_t)offset;

/**
 *  @brief  读取整个文件Data数据
 *
 *  @param filePath 文件路径
 *
 *  @return 文件Data数据
 */
- (NSData *)DPSMReadFile:(NSString *)filePath;


@end
