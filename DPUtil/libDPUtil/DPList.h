//
//  DPCallList.h
//  TProtocol
//
//  Created by anping on 8/14/11.
//  Copyright 2011 D-Power. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef	struct listNode {
	void				*data;
	struct listNode		*next;
}DPListNode;

@interface DPList : NSObject {
}

- (void*)DPGetNodeFromHead;
- (BOOL)DPAddNodeToTail:(void*)pMsgNode;
- (void)DPDeleteAllNode;

@end
