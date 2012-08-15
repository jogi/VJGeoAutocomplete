//
//  VJGeoPrediction.m
//  Bay Area Transit
//
//  Created by Vashishtha Jogi on 8/12/12.
//  Copyright (c) 2012 vashishthajogi.com. All rights reserved.
//

#import "VJGeoPrediction.h"

@implementation VJGeoPrediction

@synthesize formattedDescription=_formattedDescription;
@synthesize terms=_terms;
@synthesize matchedSubstrings=_matchedSubstrings;

-(id)initWithDescription:(NSString *)formattedDescription terms:(NSArray *)terms matchedSubstrings:(NSArray *)matchedSubstrings
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.formattedDescription = formattedDescription;
    self.terms = terms;
    self.matchedSubstrings = matchedSubstrings;
    
    return self;
}

- (NSString *)titleForTableViewCell
{
    if (self.terms.count > 0) {
        return [[self.terms objectAtIndex:0] valueForKey:@"value"];
    }
    return @"";
}

- (NSString *)subtitleForTableViewCell
{
    if (self.terms.count > 1) {
        NSMutableArray *subterms = [[NSMutableArray alloc] init];
        for (NSDictionary *term in [self.terms subarrayWithRange:NSMakeRange(1, self.terms.count - 1)]) {
            [subterms addObject:[term valueForKey:@"value"]];
        }
        return [subterms componentsJoinedByString:@", "];
    }
    return @"";
}

- (NSString *)description {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.terms, @"terms",
                          self.matchedSubstrings, @"matchedSubstrings",
                          self.formattedDescription, @"formattedDescription", nil];
	
	return [dict description];
}

@end
