#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#include "ExtensionKitIPhone.h"
#include "OpenflIosNetworking.h"

namespace openfl_ios_networking {

	NSDictionary * parseJsonObject(const char *json) {
		NSData * data = [[[NSString alloc] initWithCString: json encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
		
		NSLog([[NSString alloc] initWithCString: json encoding:NSUTF8StringEncoding]);

		NSError * jsonError;
		
		id parsedThing = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
		if (parsedThing == nil)	{
		    // Error
		    return nil;
		} else if ([parsedThing isKindOfClass: [NSArray class]]) {
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

		NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
		config.HTTPAdditionalHeaders = header;

		NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
	
		// NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
		NSData *data = [makeParamtersString(parameters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]; 

		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
		request.HTTPMethod = method;
		// [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		// [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
		[request addValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-Length"];

		if ([@"POST" isEqual:method]) {
			[request setHTTPBody:data];
		}

		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

		__block NSData *inData;
		__block NSURLResponse *response;
		__block NSError *error;

		NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
			// NSLog(@"completionHandler. Data=%@", [[NSString alloc] initWithCString: (char *)d.bytes encoding:NSUTF8StringEncoding]);
            inData = [[NSData alloc] initWithData: d];
			response = r;
			error = e;
			dispatch_semaphore_signal(semaphore);
		}];

		
		// dispatch_sync(dispatch_get_main_queue(), ^{});


		[task resume];

		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		dispatch_release(semaphore);

		extensionkit::DispatchEventToHaxeInstance(eventDispatcherId, "IOSNetworkingEvent",
              extensionkit::CSTRING, "openfl_ios_networking_complete",
              extensionkit::CSTRING, (nil != [inData bytes] && *(char *)[inData bytes] != 0) ? (const char *)[inData bytes] : "ERROR",
              extensionkit::CSTRING, (nil != error) 
              				? ((NULL != [[error localizedDescription] UTF8String]) ? [[error localizedDescription] UTF8String] : "ERROR")
              				: "SUCCESS",
              extensionkit::CEND);

		[inData release];
	}
}
