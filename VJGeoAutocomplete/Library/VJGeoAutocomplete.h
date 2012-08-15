//
// VJGeoAutocomplete.h
//
// Created by Vashishtha Jogi on 08/23/12.
// Copyright 2012 vashishthajogi.com. All rights reserved.
//
// https://github.com/jvashishtha/VJGeoAutocomplete
// https://maps.googleapis.com/maps/api/place/
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VJGeoPrediction.h"

typedef enum {
	VJGeoAutocompleteZeroResultsError = 1,
	VJGeoAutocompleteOverQueryLimitError,
	VJGeoAutocompleteRequestDeniedError,
	VJGeoAutocompleteInvalidRequestError,
    VJGeoAutocompleteJSONParsingError
} VJGeoAutocompleteError;

@interface VJGeoAutocomplete : NSOperation

+ (VJGeoAutocomplete*)autocomplete:(NSString *)address completion:(void (^)(NSArray *predictions, NSError *error))block;
+ (VJGeoAutocomplete*)autocomplete:(NSString *)address location:(CLLocationCoordinate2D)location radius:(CLLocationDistance)radius completion:(void (^)(NSArray *predictions, NSError *error))block;

- (void)cancel;

@property (readonly, getter = isQuerying) BOOL querying;

- (void)startAsynchronous;

@end