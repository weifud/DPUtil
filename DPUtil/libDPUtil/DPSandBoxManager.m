//
//  DPSandBoxController.m
//  SmartHome
//
//  Created by weifu Deng on 10/18/14.
//  Copyright (c) 2014 digital power. All rights reserved.
//

#import "DPSandBoxManager.h"

@interface DPSandBoxManager ()

@end

@implementation DPSandBoxManager

+ (DPSandBoxManager *)defaultManager{
    static DPSandBoxManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

//获取Home目录
- (NSString *)DPSMGetHomeDir{
    return NSHomeDirectory();
}

//获取Document目录
- (NSString *)DPSMGetDocumentDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取Cache目录
- (NSString *)DPSMGetCacheDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取Library目录
- (NSString *)DPSMGetLibraryDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取Tmp目录
- (NSString *)DPSMGetTmpDir{
    return NSTemporaryDirectory();
}

//判断dirPath文件夹是否存在
- (BOOL)DPSMIsDirExist:(NSString *)dirPath{
    BOOL result = NO;
    BOOL isDir = NO;
    
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if(isDirExist && isDir){
        result = YES;
    }

    return result;
}

//判断filePath文件是否存在
- (BOOL)DPSMIsFileExist:(NSString *)filePath{
    BOOL result = NO;
    BOOL isDir = NO;
    
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if(isFileExist && !isDir){
        result = YES;
    }
 
    return result;
}

//在path目录下创建newDirname目录
- (BOOL)DPSMCreatDirInPath:(NSString *)path NewDicName:(NSString *)newDirname{
    BOOL bCreateDir = NO;
    NSString *newDirPath = [path stringByAppendingPathComponent:newDirname];
    if (![self DPSMIsDirExist:newDirPath]){
        bCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:newDirPath
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:nil];
    }
    else{
        bCreateDir = YES;
    }
    
    if(!bCreateDir)
        NSLog(@"Create Directory Failed.");
    
    return bCreateDir;
}

//在path目录下创建newFileName文件并写入数据
- (BOOL)DPSMCreatFileInPath:(NSString *)path NewFileName:(NSString *) newFileName Data:(NSData *)pData{
    BOOL bCreateFile = NO;
    NSString *newFilePath = [path stringByAppendingPathComponent:newFileName];
    if (![self DPSMIsFileExist:newFilePath]){
        bCreateFile = [[NSFileManager defaultManager] createFileAtPath:newFilePath
                                                              contents:pData
                                                            attributes:nil];
    }
    
    if(!bCreateFile)
        NSLog(@"Create File Failed.");
    
    return bCreateFile;
}

//获取path路径一级子文件(夹)并保存到subArr
-(void)DPSMGet1stLevSubFileInPath:(NSString *)path SubFileArr:(NSMutableArray *)subArr{
    if ([self DPSMIsDirExist:path]){
        [subArr removeAllObjects];
        //NSArray *filesArr = [[NSFileManager defaultManager] subpathsAtPath:path];
        NSArray *filesArr = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
        [subArr addObjectsFromArray:filesArr];
        
        //提取非一级子文件(夹)
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (int pos = 0; pos < [subArr count]; pos++) {
            NSString *pFilePath = [subArr objectAtIndex:pos];
            NSRange range=[pFilePath rangeOfString:@"/"];
            if (range.location != NSNotFound) {
                [indexSet addIndex:pos];
            }
        }
        
        //移除非一级子文件(夹)
        [subArr removeObjectsAtIndexes:indexSet];
        [indexSet release];
    }
}

//获取path路径下的所有文件(包含该路径下所有子文件和文件夹)并保存到subArr
- (void)DPSMGetAllSubFileInPath:(NSString *)path SubFileArr:(NSMutableArray *)subArr{
    if ([self DPSMIsDirExist:path]){
        [subArr removeAllObjects];
        //NSArray *filesArr = [[NSFileManager defaultManager] subpathsAtPath:path];
        NSArray *filesArr = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
        [subArr addObjectsFromArray:filesArr];
    }
}

//删除文件(文件夹)
- (BOOL)DPSMDeleteFile:(NSString *)filePath{
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

//删除文件夹下的所有文件(文件夹保留)
- (void)DPSMDeleteAllFileInDir:(NSString *)dirPath{
    if ([self DPSMIsDirExist:dirPath]) {
        NSMutableArray *pFileList = [[NSMutableArray alloc] initWithCapacity:10];
        
        [self DPSMGetAllSubFileInPath:dirPath SubFileArr:pFileList];
        for (NSString *fileName in pFileList) {
            NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
            [self DPSMDeleteFile:filePath];
        }
        
        [pFileList release];
    }
}

//写入文件
- (BOOL)DPSMWriteNewFile:(NSData *)pData FilePath:(NSString *)filePath Replace:(BOOL)bReplace{
    BOOL bRet = NO;
    if ([self DPSMIsFileExist:filePath] && bReplace) {
        if ([self DPSMDeleteFile:filePath]) {
            bRet = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                           contents:pData
                                                         attributes:nil];
        }
        else{
            NSLog(@"replace file fail");
        }
    }
    else{//不存在则创建
        bRet = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                       contents:pData
                                                     attributes:nil];
    }
    
    return bRet;
}

//插入数据
- (BOOL)DPSMWritetoFile:(NSData *)pData FilePath:(NSString *)filePath Offset:(int64_t)offset{
    BOOL bRet = NO;
    if ([self DPSMIsFileExist:filePath]) {
        NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if(fileHandle){
            if (offset == -1) {
                [fileHandle seekToEndOfFile];//移到到末尾接着写
            }
            else{
                [fileHandle seekToFileOffset:offset];
            }
            
            [fileHandle writeData:pData];
            [fileHandle closeFile];

        }
    }else{//不存在则创建
        bRet = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                       contents:pData
                                                     attributes:nil];
    }
    
    return bRet;
}

//读数据
- (NSData *)DPSMReadDataFromFile:(NSString *)filePath LenOfData:(NSInteger)len Offset:(int64_t)offset{
    NSData *pData = nil;
    if ([self DPSMIsFileExist:filePath]){
        NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        if(fileHandle){
            [fileHandle seekToFileOffset:offset];
            if (len < 0) {
                pData = [fileHandle readDataToEndOfFile];
            }
            else{
                pData = [fileHandle readDataOfLength:len];
            }
            [fileHandle closeFile];
        }
    }
    
    return pData;
}

//读文件
- (NSData *)DPSMReadFile:(NSString *)filePath{
    NSData *pData = nil;
    if ([self DPSMIsFileExist:filePath]){
        //法一：
        pData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        
        //法二：
        //pData = [NSData dataWithContentsOfFile:filePath];
    }
    return pData;
}

@end
