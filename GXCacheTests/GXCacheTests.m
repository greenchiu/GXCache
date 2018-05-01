//
//  GXCacheTests.m
//  GXCacheTests
//
//  Created by Green on 29/04/2018.
//  Copyright © 2018 Green. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXCache.h"

@interface GXCacheTests : XCTestCase

@end

@implementation GXCacheTests

- (NSDictionary *)projectDescription
{
	return @{@"Project": @"GXCache",
			 @"Author": @"ChihChiang, Chiu (Green)",
			 @"Why this": @"I want a cache mechanism, I hope if the cache value can store in disk and lazy-loading after receiving memory warning.",
			 @"Lincese": @"MIT",
			 @"Others": @"I'm not sure the performance is good or not, it is in progress."};
}

- (NSDictionary *)aboutMe
{
	return @{@"Bio":@"I'm self-orginized and self-motivated, love to learn new things and challage myself. I have more than six years experience about iOS Development and one year experience about management.",
			 @"Work for":@"I worked for KKBOX and ihergo before. Currently, I work for honestbee @ Taipei.",
			 @"Position": @"Sr. iOS Developer.",
			 @"contact me": @"I love to receive your message about iOS Develop or others, please feel free to contact me"};
}

- (void)test_GXCache {
	GXCache *cache = [GXCache new];
	[cache setObject:[self projectDescription] forKey:@"GXCache"];
	
	[cache setObject:[self aboutMe] forKey:@"About me"];
	XCTAssertTrue(cache.allKeys.count == 2);
	BOOL isEqual = [cache.allKeys isEqualToSet:[NSSet setWithObjects:@"GXCache", @"About me", nil]];
	XCTAssertTrue(isEqual);
	
	NSDictionary *project = (NSDictionary *)[cache objectForKey:@"GXCache"];
	isEqual = [project isEqualToDictionary:[self projectDescription]];
	XCTAssertTrue(isEqual);
	
	NSDictionary *aboutMe = (NSDictionary *)[cache objectForKey:@"About me"];
	isEqual = [aboutMe isEqualToDictionary:aboutMe];
	XCTAssertTrue(isEqual);
	
	for (NSString *key in cache.allKeys) {
		XCTAssertTrue([cache objectForKey:key]);
	}
}

- (void)test_maxmiumCount
{
	GXCache *cache = [GXCache new];
	cache.maximunCount = 1;
	
	[cache setObject:[self projectDescription] forKey:@"GXCache"];
	[cache setObject:[self aboutMe] forKey:@"About me"];
	
	XCTAssertTrue(cache.allKeys.count == 1);
	XCTAssertNil([cache objectForKey:@"GXCache"]);
	XCTAssertNotNil([cache objectForKey:@"About me"]);
}

- (void)test_capacity
{
	GXCache *cache = [GXCache new];
	cache.capacity = 400;
	
	[cache setObject:[self projectDescription] forKey:@"GXCache"];
	[cache setObject:[self aboutMe] forKey:@"About me"];
	
	XCTAssertTrue(cache.allKeys.count == 1);
	XCTAssertNil([cache objectForKey:@"GXCache"]);
	XCTAssertNotNil([cache objectForKey:@"About me"]);
}

- (void)test_removeObject
{
	GXCache *cache = [GXCache new];
	[cache setObject:[self projectDescription] forKey:@"GXCache"];
	[cache setObject:[self aboutMe] forKey:@"About me"];
	XCTAssertTrue(cache.allKeys.count == 2);
	
	[cache removeObjectForKey:@"GXCache"];
	XCTAssertNil([cache objectForKey:@"GXCache"]);
	XCTAssertTrue(cache.allKeys.count == 1);
	
	[cache setObject:nil forKey:@"About me"];
	XCTAssertNil([cache objectForKey:@"About me"]);
	XCTAssertTrue(cache.allKeys.count == 0);
}

- (void)test_zap
{
	GXCache *cache = [GXCache new];
	[cache setObject:[self projectDescription] forKey:@"GXCache"];
	[cache setObject:[self aboutMe] forKey:@"About me"];
	XCTAssertTrue(cache.allKeys.count == 2);
	[cache zap];
	XCTAssertFalse(cache.allKeys.count);
}



@end
