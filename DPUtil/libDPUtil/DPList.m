//
//  DPCallList.m
//  TProtocol
//
//  Created by anping on 8/14/11.
//  Copyright 2011 D-Power. All rights reserved.
//

#import "DPList.h"

@interface DPList ()
{
    NSLock		*listLock;
    DPListNode	*listHeader;
    DPListNode	*listTail;
}

@end

@implementation DPList

- (id)init{
    self = [super init];
    if (self) {
        listLock = [[NSLock alloc] init];
        listHeader = listTail = NULL;
    }
    
    return self;
}

- (void)dealloc{
    [listLock release];
    [super dealloc];
}

/* Get Node & Remove it form list */
- (void*)DPGetNodeFromHead {
	DPListNode *pNode = NULL;
	void *pData = NULL;
	[listLock lock];
	if (listHeader == NULL) {
		[listLock unlock];
		return NULL;
	}
	if (listHeader == listTail) {
		pNode = listHeader;
		pData = listHeader->data;
		listHeader = listTail = NULL;
	}else {
		pNode = listHeader;
		pData = listHeader->data;
		listHeader = listHeader->next;
	}
	free(pNode);
	[listLock unlock];
    
	return pData;
}

- (BOOL)DPAddNodeToTail:(void*) pNodeData {
	DPListNode *pNode;
	if (pNodeData == NULL) {
		return YES;
	}
	
	[listLock lock];
	pNode = (DPListNode *)malloc(sizeof(DPListNode));
	if (pNode == NULL) {
		NSLog(@"Not Enough Memory");
		[listLock unlock];
		return NO;
	}
	pNode->data= pNodeData;
	pNode->next = NULL;
	if (listHeader == NULL && listTail == NULL) {
		listTail = pNode;		
		listHeader = listTail;
	}else {
		listTail->next = pNode;
		listTail = pNode;
	}
    
	[listLock unlock];
	
	return YES;
}
	
- (void)DPDeleteAllNode {
	DPListNode *pNode;
	[listLock lock];
	if (listHeader != NULL && listHeader != listTail) {
		while (listHeader != NULL) {
			pNode = listHeader;
			listHeader=listHeader->next;
			free(pNode->data);
		    free(pNode);
		}
	}
	[listLock unlock];
}

@end
