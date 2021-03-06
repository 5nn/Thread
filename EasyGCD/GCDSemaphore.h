//
//  GCDSemaphore.h
//  EasyGCD
//
//  Created by mike on 17/11/2016.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDSemaphore : NSObject
@property (strong, readonly, nonatomic) dispatch_semaphore_t dispatchSemaphore;

#pragma 初始化
- (instancetype)init;
- (instancetype)initWithValue:(long)value;

#pragma mark - 用法
- (BOOL)signal;
- (void)wait;
- (BOOL)wait:(int64_t)delta;

@end
