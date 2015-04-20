//
//  WRFiledownLoadTool.m
//  WRFileDownLoad
//
//  Created by zjsruxxxy3 on 15/4/19.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import "WRFileDownLoadTool.h"

@interface WRFileDownLoadTool ()<NSURLConnectionDataDelegate>

@property(nonatomic,strong)NSURLConnection *urlCon;


@property(nonatomic,strong)NSFileHandle *writeHandle;

@property(nonatomic,assign)long long currentFileLength;

@property(nonatomic,assign)long long totalFileLength;


@end

@implementation WRFileDownLoadTool

+(instancetype)fileDownLoadWithWebPath:(NSString *)webPath FileName:(NSString *)fileName;
{
    
    return [[WRFileDownLoadTool alloc]initWithWebPath:webPath FileName:fileName];
    
}

-(instancetype)initWithWebPath:(NSString *)webPath FileName:(NSString *)fileName
{
    if (self = [super init])
    {
        self.fileName = fileName;
        self.webPath = webPath;
    }
    
    return self;
}

#pragma mark -WRFileDownLoadToolMainFunction
-(void)startDonwLoadWithHanle:(void (^)())handle
{
    
    _downLoading = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.webPath,self.fileName]];
    
    NSMutableURLRequest *URLReq = [[NSMutableURLRequest alloc]initWithURL:url];
    [URLReq setValue:[NSString stringWithFormat:@"bytes=%lld-",self.currentFileLength]
  forHTTPHeaderField:@"Range"];
    
    NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:URLReq
                     delegate:self];
    
    self.urlCon = urlConnection;
    
    [urlConnection start];
    
    if (handle)
    {
        handle();

    }
    
}

-(void)pauseDonwLoadWithHanle:(void (^)())handle
{
    _downLoading = NO;
    
    [self.urlCon cancel];
    
    self.urlCon = nil;
    
    if (handle)
    {
        handle();
        
    }
}

-(void)cancelDonwLoadWithHanle:(void (^)())handle
{
    [self.writeHandle closeFile];
    self.writeHandle = nil;
    self.currentFileLength = 0;
    _downLoading = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cachePath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *destinationFilePath = [cachePath stringByAppendingPathComponent:self.fileName];
    
    NSError *error = [[NSError alloc]init];
    
    if ([fileManager fileExistsAtPath:destinationFilePath])
    {
        [fileManager removeItemAtPath:destinationFilePath error:&error];
        
        if (handle)
        {
            handle();
            
        }
    }else
    {
        NSLog(@"no file exists");
    }
}

#pragma mark -NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if (self.handleFail)
    {
        self.handleFail(error);

    }
    
    NSLog(@"%@",error);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    if (self.handleStart)
    {
        self.handleStart();
    }
    
    if(self.currentFileLength != 0) return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cachePath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *destinationFilePath = [cachePath stringByAppendingPathComponent:self.fileName];
    
    [fileManager createFileAtPath:destinationFilePath contents:nil attributes:nil];
    
    NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:destinationFilePath];
    
    self.writeHandle = writeHandle;
    
    self.currentFileLength = 0;
    
    self.totalFileLength = [response expectedContentLength];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    
    self.currentFileLength += data.length;
    double progress = (double)self.currentFileLength/self.totalFileLength;
    
    BOOL success = progress == 1? YES:NO;

    if (self.handleProgress)
    {
        self.handleProgress(progress,success);
    }
    
    [self.writeHandle seekToEndOfFile];
    [self.writeHandle writeData:data];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [self.writeHandle closeFile];
    self.writeHandle = nil;
    self.currentFileLength = 0;
    _downLoading = NO;
    
    if (self.handleCompletion)
    {
        self.handleCompletion();
    }
    
}

@end
