//
//  NSObject+CancelableBlock.h
//  Bay Area Transit
//
//  Created by Vashishtha Jogi on 8/13/12.
//  Copyright (c) 2012 vashishthajogi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CancelableBlock)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay cancelPreviousRequest:(BOOL)cancel;

@end
