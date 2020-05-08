#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#include "ExtensionKitIPhone.h"
#include "Utils.h"


namespace iosnetworking {
	
	NSDictionary * parseJsonObject(const char *json) {
		NSString * jsonString = [[NSString alloc] initWithCString: json encoding:NSUTF8StringEncoding];
		NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
		
		NSError * jsonError;
		
		id parsedThing = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
		if (parsedThing == nil)	{
			NSLog(@"iosnetworking::parseJsonObject Error: data can not be parsed");
		    // Error
		    return nil;
		} else if ([parsedThing isKindOfClass: [NSArray class]]) {
			NSLog(@"iosnetworking::parseJsonObject Error: parsed data is array");
		    // handle array, parsedThing can be cast as an NSArray safely
		    return nil;
		} else {
		    // handle dictionary, parsedThing can be cast as an NSDictionary
		    // NB only dictionaries and arrays allowed as long as NSJSONReadingAllowFragments 
		    // not specified in the options
		    return (NSDictionary *) parsedThing;
		}	
	}

	NSString * URLEscaped (NSString *strIn, NSStringEncoding encoding) {
	    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)strIn, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", CFStringConvertNSStringEncodingToEncoding(encoding));
	    NSString *strOut = [NSString stringWithString:(__bridge NSString *)escaped];
	    CFRelease(escaped);
	    return strOut;
	}

	NSString * makeParamtersString(NSDictionary *parameters, NSStringEncoding encoding) {
	    if (nil == parameters || [parameters count] == 0)
	        return nil;

	    NSMutableString* stringOfParamters = [[NSMutableString alloc] init];
	    NSEnumerator *keyEnumerator = [parameters keyEnumerator];
	    id key = nil;
	    while ((key = [keyEnumerator nextObject]))
	    {
	        NSString *value = [[parameters valueForKey:key] isKindOfClass:[NSString class]] ?
	        [parameters valueForKey:key] : [[parameters valueForKey:key] stringValue];
	        [stringOfParamters appendFormat:@"%@=%@&",
	         URLEscaped(key, encoding),
	         URLEscaped(value, encoding)];
	    }

	    // Delete last character of '&'
	    NSRange lastCharRange = {[stringOfParamters length] - 1, 1};
	    [stringOfParamters deleteCharactersInRange:lastCharRange];

	    return stringOfParamters;
	}


	void httpRequest(int eventDispatcherId, const char *urlValue,  const char *methodValue, const char *headerJson, const char *parametersJson) {
		NSURL * url = [NSURL URLWithString: [[NSString alloc] initWithCString: urlValue encoding:NSUTF8StringEncoding]];
		NSString * method = [[NSString alloc] initWithCString: methodValue encoding:NSUTF8StringEncoding];
		NSDictionary * header = parseJsonObject(headerJson);
		NSDictionary * parameters = parseJsonObject(parametersJson);

		// NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
		NSData *data = [makeParamtersString(parameters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]; 

		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
		request.HTTPMethod = method;
		request.allHTTPHeaderFields = header;
		if (@available(iOS 13, *)) {
		    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
		} else {
		    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
		}
		// [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		// [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

		if ([@"POST" isEqual:method]) {
			[request addValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-Length"];
			[request setHTTPBody:data];
		}

		NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
			// if (nil != d) {
			// 	NSLog(@"completionHandler. Data=%@", [[NSString alloc] initWithCString: (char *)d.bytes encoding:NSUTF8StringEncoding]);
			// } else {
			// 	NSLog(@"completionHandler. Data=nil");
			// }
			dispatch_sync(dispatch_get_main_queue(), ^{
				      extensionkit::DispatchEventToHaxeInstance(eventDispatcherId, "IOSNetworkingEvent",
			              extensionkit::CSTRING, "openfl_ios_networking_complete",
			              extensionkit::CSTRING, (nil != [d bytes] && *(char *)[d bytes] != 0) ? (const char *)[d bytes] : "ERROR",
			              extensionkit::CSTRING, (nil != e) 
			              				? ((NULL != [[e localizedDescription] UTF8String]) ? [[e localizedDescription] UTF8String] : "ERROR")
			              				: "SUCCESS",
			              extensionkit::CEND);
				
			});
		}];


		[task resume];
	}
	
	
}
