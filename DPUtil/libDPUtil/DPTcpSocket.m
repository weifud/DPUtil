//
//  DPTcpSocket.m
//  DPRing
//
//  Created by weifu Deng on 3/7/16.
//  Copyright © 2016 Digital Power. All rights reserved.
//

#import "DPTcpSocket.h"

#import <CFNetwork/CFNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <arpa/inet.h>
#import <fcntl.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <netinet/in.h>
#import <net/if.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <sys/ioctl.h>
#import <sys/poll.h>
#import <sys/uio.h>
#import <unistd.h>

#ifndef INVALID_SOCKET
#define INVALID_SOCKET (-1)
#endif

@implementation DPTimevl : NSObject
@synthesize tv_sec;
@synthesize tv_usec;
@end

@interface DPTcpSocket ()
{
    CFReadStreamRef		mReadStream;
    CFWriteStreamRef	mWriteStream;
}

@end

@implementation DPTcpSocket

- (id)init{
    self = [super init];
    if (self){
        _bConnect = NO;
        _bBGVoip = NO;
        mReadStream = NULL;
        mWriteStream = NULL;
        _iSock = INVALID_SOCKET;
        
        _tvConncet = [[DPTimevl alloc] init];
        _tvConncet.tv_sec = 10.0f;
        _tvConncet.tv_usec = 0;
        
        _tvRecv = [[DPTimevl alloc] init];
        _tvRecv.tv_sec = 5.0f;
        _tvRecv.tv_usec = 0;
    }
    
    return self;
}

- (void)deallo{
    [self DPTcpDisconnect];
    [_tvConncet release];
    [_tvRecv release];
    [super dealloc];
}

- (int32_t)host2Intip:(NSString *)hostNstr{
    char szServerIPAddr[32] = {0};
    const char *szHostUrl = [hostNstr cStringUsingEncoding:NSUTF8StringEncoding];
    struct hostent	*host = gethostbyname(szHostUrl);
    if (!host) {
        herror("DNS failure");
        return -1;
    }
    
    char **pptr = (char**)host->h_addr_list;
    for (; *pptr != NULL; pptr++) {
        inet_ntop(host->h_addrtype, *pptr, szServerIPAddr, sizeof(szServerIPAddr));
    }
    
    NSLog(@"host ip:%s", szServerIPAddr);
    return inet_addr(szServerIPAddr);
}

- (void)resetVoipStream{
    if (mReadStream){
        CFReadStreamClose(mReadStream);
        CFRelease(mReadStream);
        mReadStream = NULL;
    }
    
    if (mWriteStream){
        CFWriteStreamClose(mWriteStream);
        CFRelease(mWriteStream);
        mWriteStream = NULL;
    }
}

- (BOOL)setVoipStream{
    if (mReadStream || mWriteStream) {
        NSLog(@"stream already exists");
        return NO;
    }
   
    //NSLog(@"creating read and write stream...");
    CFStreamCreatePairWithSocket(NULL, (CFSocketNativeHandle)_iSock,
                                 &mReadStream, &mWriteStream);
    if (!mReadStream || !mWriteStream){
        NSLog(@"unable to create read and write stream");
        return NO;
    }

    // The kCFStreamPropertyShouldCloseNativeSocket property should be false by default
    //(for our case).
    // But let's not take any chances.
    CFReadStreamSetProperty(mReadStream,
                            kCFStreamPropertyShouldCloseNativeSocket,
                            kCFBooleanFalse);
    CFWriteStreamSetProperty(mWriteStream,
                             kCFStreamPropertyShouldCloseNativeSocket,
                             kCFBooleanFalse);
    BOOL bR1 = CFReadStreamSetProperty(mReadStream,
                                       kCFStreamNetworkServiceType,
                                       kCFStreamNetworkServiceTypeVoIP);
    BOOL bR2 = CFWriteStreamSetProperty(mWriteStream,
                                        kCFStreamNetworkServiceType,
                                        kCFStreamNetworkServiceTypeVoIP);
    if (!bR1 || !bR2){
        NSLog(@"error setting voip type");
        return NO;
    }
    
    CFStreamStatus readStatus = CFReadStreamGetStatus(mReadStream);
    CFStreamStatus writeStatus = CFWriteStreamGetStatus(mWriteStream);
    if ((readStatus == kCFStreamStatusNotOpen) ||
        (writeStatus == kCFStreamStatusNotOpen)){
        bR1 = CFReadStreamOpen(mReadStream);
        bR2 = CFWriteStreamOpen(mWriteStream);
        
        if (!bR1 || !bR2){
            NSLog(@"error opening bg streams");
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)creatSock{
    _iSock = socket(PF_INET, SOCK_STREAM, 0);
    if (_iSock == INVALID_SOCKET) {
        NSLog(@"creat socket error");
        return NO;
    }
    
    /*!
     *屏蔽SIGPIPE信号,等同于signal(SIGPIPE,SIG_IGN);
     *SIGPIPE信号
     *在linux下写socket的程序的时候，如果尝试send到一个disconnected socket上，就会让底层抛出一个SIGPIPE信号。
     *该信号的缺省处理方法是退出进程。
     */
    int nosigpipe = 1;
    setsockopt(_iSock, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    
    //地址复用，解决端口被占用问题
    int reuseOn = 1;
    int status = setsockopt(_iSock, SOL_SOCKET, SO_REUSEADDR, &reuseOn, sizeof(reuseOn));
    if (status == -1) {
        NSLog(@"enbaling address reuse error");
        close(_iSock);
        _iSock = INVALID_SOCKET;
        return NO;
    }
    
    return YES;
}

- (BOOL)connectWithIP:(int32_t)ip Port:(int32_t)port{
    if (_iSock == INVALID_SOCKET) {
        NSLog(@"connect err: invalid socket");
        return NO;
    }
    
    struct sockaddr_in sin;
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = ip;
    //////////////////////connect///////////////////////////
    /*
     *1.设置成非阻塞模式来控制链接超时
     *2.成功链接后再设为阻塞模式
     */
    //1.设置非阻塞
    int flags = fcntl(_iSock, F_GETFL,0);
    fcntl(_iSock,F_SETFL, flags | O_NONBLOCK);
    
    int status = connect(_iSock, (const struct sockaddr*)&sin, sizeof(sin));
    if (status == -1){
        if (errno == EINPROGRESS){
            //it is in the connect process
            fd_set          fdwrite;
            struct timeval  tvSelect;
            
            int error;
            int len=sizeof(int);
            FD_ZERO(&fdwrite);
            FD_SET(_iSock, &fdwrite);
            
            tvSelect.tv_sec = _tvConncet.tv_sec;
            tvSelect.tv_usec = _tvConncet.tv_usec;
            
            int ret = select(_iSock + 1, NULL, &fdwrite, NULL, &tvSelect);
            if( ret <= 0){//time out
                NSLog(@"connect err: connect to host(%s) timeout", inet_ntoa(sin.sin_addr));
                close(_iSock);
                _iSock = INVALID_SOCKET;
                return NO;
            }
            
            //判断是否链接成功
            getsockopt(_iSock, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
            if (error != 0) {
                NSLog(@"conncet err: connect to host(%s) failed [%d(%s)]",
                      inet_ntoa(sin.sin_addr), error, strerror(error));
                close(_iSock);
                _iSock = INVALID_SOCKET;
                return NO;
            }
        }
        else{
            // NSLog(@"connect to host %s error", inet_ntoa(sin.sin_addr));
            NSLog(@"connect err: connect to host failed [%d(%s)]", errno, strerror(errno));
            close(_iSock);
            _iSock = INVALID_SOCKET;
            return NO;
        }
    }
    
    //2.连接成功后设置阻塞模式
    flags = fcntl(_iSock, F_GETFL,0);
    flags &= ~ O_NONBLOCK;
    fcntl(_iSock,F_SETFL, flags);
    
    return YES;
}

- (void)closeSocket{
    if (_bConnect) {
        shutdown(_iSock, SHUT_RDWR);
        close(_iSock);
        _bConnect = NO;
    }
}

#pragma mark - public
- (BOOL)DPTcpConnectWithIntIP:(int32_t)ip Port:(int32_t)port{
    if (_bConnect) {
        return YES;
    }

    if (![self creatSock]) {
        NSLog(@"conncet: creat sock fail");
        return NO;
    }
    
    //连接目标主机
    BOOL bRet = [self connectWithIP:ip Port:port];
    if (bRet && _bBGVoip) {
        //设置后台voip
        if (![self setVoipStream]) {
            [self DPTcpDisconnect];
            bRet = NO;
        }
    }
    
    _bConnect = bRet;
    
    return bRet;
}

- (BOOL)DPTcpConnectWithHostName:(NSString *)hostNstr Port:(int32_t)iPort{
    int32_t ip = [self host2Intip:hostNstr];
    if (ip != -1) {
        return [self DPTcpConnectWithIntIP:ip Port:iPort];
    }
    else {
        return NO;
    }
}

/*
 *@return value:
 *            0: time out or iLen <=0
 *           -1: error
 *           -2: remote close
 *        other: length of recv data 
 */
- (int)DPTcpReadData:(char *)pData LenOfData:(int)iLen{
    int ret;
    int rlen = 0;
    ssize_t len;
    
    struct timeval tv_out;
    tv_out.tv_sec = _tvRecv.tv_sec;
    tv_out.tv_usec = _tvRecv.tv_usec;
    
    if (!_bConnect) {
        NSLog(@"recv err: not connected");
        return -1;
    }
    
    fd_set	readfds;
    while (rlen < iLen){
        FD_ZERO(&readfds);
        FD_SET(_iSock, &readfds);
        
        ret = select(_iSock + 1, &readfds, NULL, NULL, &tv_out);
        if (ret < 0)    // err
            return -1;
        else if (ret == 0)
            return 0;  // time out
        
        if (FD_ISSET(_iSock, &readfds)){  //测试mSock是否可读，即是否网络上有数据
            len = recv(_iSock, pData + rlen, iLen - rlen, 0);
            if (len < 0)    // err
                return -1;
            else if (len == 0)  //connection closed by remote
                return -2;
            else
                rlen += len;
        }
    }
    
    return rlen;
}

- (int)DPTcpWriteData:(char *)pData LenOfData:(int)iLen{
    int wlen = 0;
    ssize_t len;
    
    if (!_bConnect) {
        NSLog(@"send err: not connected");
        return -1;
    }
    
    while (wlen < iLen){
        len = send(_iSock, pData + wlen, iLen - wlen, 0);
        if (len == -1){
            return wlen;
        }
        else if (len == 0) {
            return 0;
        }
        else {
            wlen += len;
        }
    }
    
    return wlen;
}

- (void)DPTcpDisconnect{
    [self resetVoipStream];
    [self closeSocket];
}

@end
