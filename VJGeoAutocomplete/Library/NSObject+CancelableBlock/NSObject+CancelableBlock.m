//
//  NSObject+CancelableBlock.m
//  Bay Area Transit
//
//  Created by Vashishtha Jogi on 8/13/12.
//  Copyright (c) 2012 vashishthajogi.com. All rights reserved.
//

#import "NSObject+CancelableBlock.h"

@implementation NSObject (CancelableBlock)

- (void)delayedAddOperation:(NSOperation *)operation {
    [[NSOperationQueue currentQueue] addOperation:operation];
}



- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(delayedAddOperation:)
               withObject:[NSBlockOperation blockOperationWithBlock:block]
               afterDelay:delay];
}



- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay cancelPreviousRequest:(BOOL)cancel {
    if (cancel) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    [self performBlock:block afterDelay:delay];
}

@end
