//
// VJGeoAutocomplete.h
//
// Created by Vashishtha Jogi on 08/23/12.
// Copyright 2012 vashishthajogi.com. All rights reserved.
//
// https://github.com/jvashishtha/VJGeoAutocomplete
// https://maps.googleapis.com/maps/api/place/
//

#import "VJGeoAutocomplete.h"
#import "JSONKit.h"

#define kVJGeoAutocompleteTimeoutInterval 20
#define kVJGeoAutocompleteGoogleAPIKey @"CHANGE ME"

enum {
    VJGeoAutocompleteRequestStateReady = 0,
    VJGeoAutocompleteRequestStateExecuting,
    VJGeoAutocompleteRequestStateFinished
};

typedef NSUInteger VJGeoAutocompleteRequestState;


@interface NSString (URLEncoding)
- (NSString*)encodedURLParameterString;
@end


@interface VJGeoAutocomplete ()

- (VJGeoAutocomplete*)initWithParameters:(NSMutableDictionary*)parameters completion:(void (^)(NSArray *, NSError*))block;
- (void)addParametersToRequest:(NSMutableDictionary*)parameters;
- (void)finish;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@property (nonatomic, strong) NSString *requestString;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, readwrite) VJGeoAutocompleteRequestState state;

@property (nonatomic, strong) NSTimer *timeoutTimer; // see http://stackoverflow.com/questions/2736967
@property (nonatomic, copy) void (^completionBlock)(NSArray *placemarks, NSError *error);

@end

@implementation VJGeoAutocomplete

@synthesize requestString, responseData, connection, request, state, timeoutTimer, completionBlock;
@synthesize querying = _querying;

#pragma mark -
#pragma mark - Convenience Initializers

+ (VJGeoAutocomplete *)autocomplete:(NSString *)address completion:(void (^)(NSArray *, NSError *))block {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       address, @"input", nil];
    VJGeoAutocomplete *autocomplete = [[self alloc] initWithParameters:parameters completion:block];
    [autocomplete start];
    return autocomplete;
}

+ (VJGeoAutocomplete*)autocomplete:(NSString *)address location:(CLLocationCoordinate2D)location radius:(CLLocationDistance)radius completion:(void (^)(NSArray *predictions, NSError *error))block
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       address, @"input",
                                       [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude], @"location",
                                       [NSString stringWithFormat:@"%f", radius], @"radius", nil];
    VJGeoAutocomplete *autocomplete = [[self alloc] initWithParameters:parameters completion:block];
    [autocomplete start];
    return autocomplete;
}

#pragma mark - Private Utility Methods

- (VJGeoAutocomplete*)initWithParameters:(NSMutableDictionary*)parameters completion:(void (^)(NSArray *, NSError *))block {
    self = [super init];
    self.completionBlock = block;
    self.request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/json"]];
    [self.request setTimeoutInterval:kVJGeoAutocompleteTimeoutInterval];
    
    [parameters setValue:@"true" forKey:@"sensor"];
    [parameters setValue:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] forKey:@"language"];
    [parameters setValue:kVJGeoAutocompleteGoogleAPIKey forKey:@"key"];
    [self addParametersToRequest:parameters];
    
    self.state = VJGeoAutocompleteRequestStateReady;
    
    return self;
}

- (void)addParametersToRequest:(NSMutableDictionary*)parameters {
    
    NSMutableArray *paramStringsArray = [NSMutableArray arrayWithCapacity:[[parameters allKeys] count]];
    
    for(NSString *key in [parameters allKeys]) {
        NSObject *paramValue = [parameters valueForKey:key];
		if ([paramValue isKindOfClass:[NSString class]]) {
			[paramStringsArray addObject:[NSString stringWithFormat:@"%@=%@", key, [(NSString *)paramValue encodedURLParameterString]]];
		} else {
			[paramStringsArray addObject:[NSString stringWithFormat:@"%@=%@", key, paramValue]];
		}
    }
    
    NSString *paramsString = [paramStringsArray componentsJoinedByString:@"&"];
    NSString *baseAddress = request.URL.absoluteString;
    baseAddress = [baseAddress stringByAppendingFormat:@"?%@", paramsString];
    [self.request setURL:[NSURL URLWithString:baseAddress]];
}

- (void)setTimeoutTimer:(NSTimer *)newTimer {
    
    if(timeoutTimer)
        [timeoutTimer invalidate], timeoutTimer = nil;
    
    if(newTimer)
        timeoutTimer = newTimer;
}

#pragma mark - NSOperation methods

- (void)start {
    
    if(self.isCancelled) {
        [self finish];
        return;
    }
    
    if(![NSThread isMainThread]) { // NSOperationQueue calls start from a bg thread (through GCD), but NSURLConnection already does that by itself
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.state = VJGeoAutocompleteRequestStateExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.responseData = [[NSMutableData alloc] init];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kVJGeoAutocompleteTimeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
    NSLog(@"[%@] %@", self.request.HTTPMethod, self.request.URL.absoluteString);
}

// private method; not part of NSOperation
- (void)finish {
    [connection cancel];
    connection = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    self.state = VJGeoAutocompleteRequestStateFinished;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.timeoutTimer = nil;
}

- (void)cancel {
    if([self isFinished])
        return;
    
    [super cancel];
    [self finish];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    return self.state == VJGeoAutocompleteRequestStateFinished;
}

- (BOOL)isExecuting {
    return self.state == VJGeoAutocompleteRequestStateExecuting;
}

- (void)startAsynchronous {
	[self start];
}


#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)requestTimeout {
    NSError *timeoutError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
    [self connection:nil didFailWithError:timeoutError];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_querying = NO;
	id response = nil;
    NSError *error = nil;
    
    if(self.responseData && self.responseData.length > 0) {
        response = [NSData dataWithData:self.responseData];
        NSDictionary *responseDict = [response objectFromJSONDataWithParseOptions:JKSerializeOptionNone error:&error];
        
        if(!error) {
            NSArray *predictionsArray = [responseDict valueForKey:@"predictions"];
            NSString *status = [responseDict valueForKey:@"status"];
            // deal with error statuses by raising didFailWithError
            
            if ([status isEqualToString:@"ZERO_RESULTS"]) {
                NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Zero results returned", NSLocalizedDescriptionKey, nil];
                error = [NSError errorWithDomain:@"VJGeoAutocompleteErrorDomain" code:VJGeoAutocompleteZeroResultsError userInfo:userinfo];
            }
            
            else if ([status isEqualToString:@"OVER_QUERY_LIMIT"]) {
                NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Currently rate limited. Too many queries in a short time. (Over Quota)", NSLocalizedDescriptionKey, nil];
                error = [NSError errorWithDomain:@"VJGeoAutocompleteErrorDomain" code:VJGeoAutocompleteOverQueryLimitError userInfo:userinfo];
            }
            
            else if ([status isEqualToString:@"REQUEST_DENIED"]) {
                NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Request was denied. Did you remember to add the \"sensor\" parameter?", NSLocalizedDescriptionKey, nil];
                error = [NSError errorWithDomain:@"VJGeoAutocompleteErrorDomain" code:VJGeoAutocompleteRequestDeniedError userInfo:userinfo];
            }
            
            else if ([status isEqualToString:@"INVALID_REQUEST"]) {
                NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:@"The request was invalid. Was the \"address\" or \"latlng\" missing?", NSLocalizedDescriptionKey, nil];
                error = [NSError errorWithDomain:@"VJGeoAutocompleteErrorDomain" code:VJGeoAutocompleteInvalidRequestError userInfo:userinfo];
            }
            
            else {
                NSMutableArray *predictionsObjArray = [NSMutableArray arrayWithCapacity:[predictionsArray count]];
                
                for(NSDictionary *predictionDict in predictionsArray) {
                    
                    VJGeoPrediction *prediction = [[VJGeoPrediction alloc] initWithDescription:[predictionDict valueForKey:@"description"]
                                                                                         terms:[predictionDict valueForKey:@"terms"]
                                                                             matchedSubstrings:[predictionDict valueForKey:@"matched_substrings"]];
                    
                    [predictionsObjArray addObject:prediction];
                }
                
                response = predictionsObjArray;
            }
        }
    }
    
    if(self.completionBlock) {
        if(error)
            self.completionBlock(nil, error);
        else
            self.completionBlock(response, error);
    }
    
    [self finish];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _querying = NO;
	
    if(self.completionBlock)
        self.completionBlock(nil, error);
        
    [self finish];
}


@end


#pragma mark -

@implementation NSString (URLEncoding)

- (NSString*)encodedURLParameterString {
    NSString *result = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (CFStringRef)self,
                                                                                            NULL,
                                                                                            CFSTR(":/=,!$&'()*+;[]@#?|"),
                                                                                            kCFStringEncodingUTF8));
	return result;
}

@end
