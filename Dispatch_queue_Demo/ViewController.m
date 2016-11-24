//
//  ViewController.m
//  Dispatch_queue_Demo
//
//  Created by mike on 15/11/2016.
//  Copyright © 2016 mike. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    [self dispatchSemphore];

                
    
    
}

- (void)dispatchSemphore{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
     dispatch_queue_t concurrentQueue = dispatch_queue_create("com.gcd.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
  
    __block NSString *strTest = @"test";
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        for (NSInteger i = 0; i < 99; i++) {
            
            NSLog(@"%@", strTest);
            
        }
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        for (NSInteger i = 0; i < 99; i++) {
            
            NSLog(@"QQQQQQQQQQQQQQQQQQQ%@", strTest);
            
        }

        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
 
    strTest = @"RRR";
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        for (NSInteger i = 0; i < 99; i++) {
            
            NSLog(@"%@", strTest);
            
        }

        dispatch_semaphore_signal(semaphore);
    });
}

#pragma mark  dispatch_apply
- (void)distApply{
    //会优化很多，能够利用GCD管理,比for循环好，防止内存暴增
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(999, concurrentQueue, ^(size_t i){
        NSLog(@"correct %zu",i);
        //do something hard
    });
}


#pragma mark dispatch barrier
- (void)dispatchBarrierAsyncDemo {
    //防止文件读写冲突，可以创建一个串行队列，操作都在这个队列中进行，没有更新数据读用并行，写用串行。
    dispatch_queue_t dataQueue = dispatch_queue_create("com.starming.gcddemo.dataqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 1");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 2");
    });
    //等待前面的都完成，在执行barrier后面的
    dispatch_barrier_async(dataQueue, ^{
        NSLog(@"write data 1");
        [NSThread sleepForTimeInterval:1];
    });
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"read data 3");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 4");
    });
}


#pragma mark 异步例子
- (void)test8{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        for (NSInteger i = 0; i < 9999; i++) {
            
                NSLog(@"第%ld次", i);
           
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            NSLog(@"99");
        });
    });
}

#pragma mark 延时执行队列
- (void)test7{
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 设置延时，单位秒
    double delay = 3;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
        // 3秒后需要执行的任务
        NSLog(@"doing");
    });
}
#pragma mark 添加依赖
- (void)test6{
    //1.任务一：下载图片
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    
    //2.任务二：打水印
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"打水印   - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    
    //3.任务三：上传图片
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"上传图片 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    
    //4.设置依赖
    [operation2 addDependency:operation1];      //任务二依赖任务一
    [operation3 addDependency:operation2];      //任务三依赖任务二
    
    //5.创建队列并加入任务
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operation3, operation2, operation1] waitUntilFinished:NO];
}

#pragma mark queue op
- (void)test5{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    //2.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@", [NSThread currentThread]);
    }];
    
    //3.添加多个Block
    for (NSInteger i = 0; i < 3399; i++) {
        [operation addExecutionBlock:^{
            NSLog(@"第%ld次：%@", i, [NSThread currentThread]);
        }];
    }
    
    //4.队列添加任务
    
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 3399; i++) {
            NSLog(@"finsh:%ld,%@", (long)i, [NSThread currentThread]);
        }

    }];
    [queue addOperations:@[operation1] waitUntilFinished:YES];
    
    [queue addOperation:operation];
    
    [queue addOperationWithBlock:^{
        
        for (NSInteger i = 0; i < 3399; i++) {
            NSLog(@"for %ld times：%@", i, [NSThread currentThread]);
        }
        
    }];
    
}
#pragma mark NSBlockOperation
- (void)test4{
//    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
//    
//     [op start];

    //1.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@", [NSThread currentThread]);
    }];
    
    //添加多个Block
    for (NSInteger i = 0; i < 5; i++) {
        [operation addExecutionBlock:^{
            NSLog(@"第%ld次：%@", i, [NSThread currentThread]);
        }];
    }
    
    //2.开始任务
    [operation start];

}

- (void)run{
    NSLog(@"run");
}
- (void)test3{
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //3.多次使用队列组的方法执行任务, 只有异步方法
    //3.1.执行3次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 3; i++) {
            NSLog(@"group-01 - %@", [NSThread currentThread]);
        }
    });
    
    //3.2.主队列执行8次循环
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 8; i++) {
            NSLog(@"group-02 - %@", [NSThread currentThread]);
        }
    });
    
    //3.3.执行5次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"group-03 - %@", [NSThread currentThread]);
        }
    });
    
    //4.都完成后会自动通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 - %@", [NSThread currentThread]);
    });
}


- (void)test2{
    dispatch_queue_t queue = dispatch_queue_create("SERIAL_Queue_for_test_2", NULL);
    
    dispatch_sync(queue, ^{
        //code here
        NSLog(@"q:%@", [NSThread currentThread]);
    });
    
    
    dispatch_queue_t queue2 = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue2, ^{
        //code here
        NSLog(@"q2:%@", [NSThread currentThread]);
    });
    //并行队列
    dispatch_queue_t queue3 = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue3, ^{
        //code here
        NSLog(@"q3:%@", [NSThread currentThread]);
    });
    dispatch_queue_t queue4 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue4, ^{
        //code here
        NSLog(@"q4:%@", [NSThread currentThread]);
    });
    

}


- (void)test1{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        for (int i; i<9999; i++) {
            NSLog(@"AAAAAAAA");
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            for (int i; i<9999; i++) {
                NSLog(@"======");
            }
            
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i; i<9999; i++) {
                NSLog(@"////////////////");
            }
        });
        
        
    });
    

}
@end
