//
//  DPParseXML.m
//  DPCloud
//
//  Created by weifu Deng on 6/26/15.
//  Copyright (c) 2015 digital power. All rights reserved.
//

#import "DPParseXML.h"

@implementation DPParseXML

+ (char *)DPGetNextNodeValueXml:(char *)pXml NodeName:(char *)pName MaxLenOfNode:(NSInteger)len Offset:(NSInteger *)offset{
    char *pStar, *pEnd, *pValue;
    char *p = strchr(pXml, '<');
    if(!p){
        return NULL;
    }
    pStar = ++p;
    
    p = strchr(pStar, '>');
    if(!p){
        return NULL;
    }
    pEnd = p;
    
    if(len < pEnd - pStar){
        return NULL;
    }
    
    strncpy(pName, pStar, pEnd - pStar);
    pName[pEnd - pStar] = 0;
    
    pStar = pEnd + 1;
    
    char node[64];
    sprintf(node,"</%s>",pName);
    pEnd = strstr(pStar,node);
    if(!pEnd){
        return NULL;
    }
    
    pValue = (char *)malloc(pEnd - pStar + 1); //\0位
    if(!pValue){
        return NULL;
    }
    memcpy(pValue, pStar, pEnd - pStar);
    pValue[pEnd - pStar] = 0;
    *offset = pEnd - pXml + strlen(node);
    
    return pValue;
}

+ (char *)DPGetNodeValueXml:(char *)pXml NodeName:(char *)pName{
    if ((strlen(pName) > 60) || (strlen(pName) > strlen(pXml))){
        return NULL;
    }
    
    char node[64];
    sprintf(node, "<%s>", pName);
    char *pStar = strstr(pXml, node);
    if(!pStar){
        return NULL;
    }
    pStar += strlen(node);
    
    memset(node, 0, 64);
    sprintf(node, "</%s>", pName);
    char *pEnd = strstr(pStar, node);
    if(!pEnd){
        return NULL;
    }
    
    char *pValue = (char *)malloc(pEnd - pStar + 1); //\0位
    if(!pValue){
        return NULL;
    }
    memcpy(pValue, pStar, pEnd - pStar);
    pValue[pEnd - pStar] = 0;  //\0

    return pValue;
}

+ (NSData *)DPGetNodeDataXml:(char *)pXml LenofData:(NSInteger)len NodeName:(NSString *)nstrName{
    NSData *pData = [NSData dataWithBytes:pXml length:len];
    NSString *nodeSName = [NSString stringWithFormat:@"<%@>", nstrName];
    NSString *nodeEName = [NSString stringWithFormat:@"</%@>", nstrName];
    NSData *pNstart = [nodeSName dataUsingEncoding: NSUTF8StringEncoding];
    NSData *pNend = [nodeEName dataUsingEncoding: NSUTF8StringEncoding];
    NSRange rangeNstar = [pData rangeOfData: pNstart options: NSDataSearchBackwards range: NSMakeRange(0, len)];
    NSRange rangeNend = [pData rangeOfData: pNend options: NSDataSearchBackwards range: NSMakeRange(0, len)];
    
    return [pData subdataWithRange: NSMakeRange(rangeNstar.location + rangeNstar.length,
                                                rangeNend.location - rangeNstar.location - rangeNstar.length)];
}

@end
