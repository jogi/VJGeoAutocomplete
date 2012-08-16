# VJGeoAutocomplete

VJGeoAutocomplete is a Objective-C wrapper for the [Google Places Autocomplete API](https://developers.google.com/places/documentation/autocomplete). It allows to autocomplete addresses. It is block-based for easy integration. For parsing the JSON response received from the Autocomplete API [JSONKit](https://github.com/johnezang/JSONKit). Make sure you read the [usage limits](https://developers.google.com/places/documentation/index#usage_limits) before using VJGeoAutocomplete.

## Installation

* Include the folder `VJGeoAutocomplete/Library` into your project
* Add *CoreLocation* to your project.
* Add flag `-fno-objc-arc` to `JSONKit.m`

## Usage
### Using the Autocomplete API

Change the value of `kVJGeoAutocompleteGoogleAPIKey` in `VJGeoAutocomplete.h` before using this. The instructions on how to obtain an API key can be accessed [here](https://developers.google.com/places/documentation/#Authentication). 

``` objective-c
[VJGeoAutocomplete autocomplete:text completion:^(NSArray *predictions, NSError *error) {
            //do something with the predictions, handle errors
            });
        }];
```

Here `predictions` is an array of `VJGeoPrediction` objects (more on that below).

To use the `location` and `radius` parameters of Autocomplete API you can do:

``` objective-c
+ (VJGeoAutocomplete*)autocomplete:(NSString *)address location:(CLLocationCoordinate2D)location radius:(CLLocationDistance)radius completion:(void (^)(NSArray *predictions, NSError *error))block;
```

### Cancelling requests

Make sure you cancel requests for which the user isn't waiting on anymore by keeping a pointer to your VJGeoAutocomplete object and calling `cancel` on it. In all cases, the request will time out after 20s.

## About the VJGeoPrediction object

`VJGeoPrediction` is basically just NSObject with a few convenience methods. Here's what it look's like:

``` json
{
    formattedDescription: "1577 Woodbine Avenue, Georgina, ON, Canada",
    matchedSubstrings: [
        {
            length: 8,
            offset: 0
        }
    ],
    terms: [
        {
            offset: 0,
            value: "1577 Woodbine Avenue"
        },
        {
            offset: 22,
            value: "Georgina"
        },
        {
            offset: 32,
            value: "ON"
        },
        {
            offset: 36,
            value: "Canada"
        }
    ],
    types: [
        "route",
        "geocode"
    ] 
}
```

## Credits

VJGeoAutocomplete is brought to you by [Vashishtha Jogi](http://vashishthajogi.com). The structure of the library is highly influenced by [Sam Vermette's](http://samvermette.com) [SVGeocoder](https://github.com/samvermette/SVGeocoder) If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/jvashishtha/VJGeoAutocomplete/issues/new). If you're using VJGeoAutocomplete in your project, attribution would be nice.

## License

[Under a Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/).