//
//  GCDGroup.h
//  EasyGCD
//
//  Created by mike on 17/11/2016.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDGroup : NSObject

@property (nonatomic, strong, readonly) dispatch_group_t dispatchGroup;

#pragma init
- (instancetype)init;

#pragma mark -method
- (void)enter;
- (void)leave;
- (void)wait;
- (BOOL)wait:(int64_t)deleta;

@end
