//
//  WRFileDownLoadTool.h
//  WRFileDownLoad
//
//  Created by zjsruxxxy3 on 15/4/19.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WRFileDownLoadTool : NSObject

@property(nonatomic,readonly,getter=isDownLoad)BOOL downLoading;

@property(nonatomic,copy)NSString *fileName;

@property(nonatomic,copy)NSString *webPath;

@property(nonatomic,copy)void(^handleStart)();

@property(nonatomic,copy)void(^handleProgress)(double progress,BOOL success);

@property(nonatomic,copy)void(^handleCompletion)();

@property(nonatomic,copy)void(^handleFail)(NSError *error);

+(instancetype)fileDownLoadWithWebPath:(NSString *)webPath FileName:(NSString *)fileName;

-(instancetype)initWithWebPath:(NSString *)webPath FileName:(NSString *)fileName;

-(void)startDonwLoadWithHanle:(void(^)()) handle;

-(void)pauseDonwLoadWithHanle:(void (^)())handle;

-(void)cancelDonwLoadWithHanle:(void (^)())handle;


@end
