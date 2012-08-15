//
//  VJGeoPrediction.h
//  Bay Area Transit
//
//  Created by Vashishtha Jogi on 8/12/12.
//  Copyright (c) 2012 vashishthajogi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VJGeoPrediction : NSObject

@property (strong, nonatomic) NSString *formattedDescription;
@property (strong, nonatomic) NSArray *terms;
@property (strong, nonatomic) NSArray *matchedSubstrings;

-(id)initWithDescription:(NSString *)formattedDescription terms:(NSArray *)terms matchedSubstrings:(NSArray *)matchedSubstrings;
- (NSString *)titleForTableViewCell;
- (NSString *)subtitleForTableViewCell;

@end
