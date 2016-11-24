//
//  GCDGroup.m
//  EasyGCD
//
//  Created by mike on 17/11/2016.
//  Copyright © 2016 mike. All rights reserved.
//

#import "GCDGroup.h"
@interface GCDGroup()

@property (nonatomic, strong, readwrite) dispatch_group_t dispatchGroup;

@end
@implementation GCDGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)enter {
    dispatch_group_enter(self.dispatchGroup);
}

- (void)leave {
    dispatch_group_leave(self.dispatchGroup);
}

- (void)wait {
    dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
}

- (BOOL)wait:(int64_t)deleta {
    return dispatch_group_wait(self.dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, deleta)) == 0;
}
@end
