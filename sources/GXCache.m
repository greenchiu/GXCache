//
//  GXCache.m
//  GXCache
//
//  Created by Green on 29/04/2018.
//  Copyright © 2018 Green. All rights reserved.
//

#import "GXCache.h"
@import UIKit;

static NSInteger const kMinimumCount = 1;
static NSInteger const kSaveCountForNodeDuringCleanCache = 1;

NSString * folderPath() {
	static NSString *path;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"gxcache"];
		
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	});
	return path;
}

@interface GXCacheNode: NSObject
- (void)cleanMemory;
@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) id<NSCoding, NSCopying> value;
@property (assign, nonatomic) NSUInteger dataSize;
@property (copy, nonatomic) NSDate *lastAccessedDate;
@end

@implementation GXCacheNode

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.identifier = [NSUUID UUID].UUIDString;
		self.dataSize = 0;
	}
	return self;
}

- (void)cleanMemory
{
	if (!_value) {
		return;
	}

	_value = nil;
}

- (void)restore
{
	NSString *filePath = [folderPath() stringByAppendingPathComponent:self.identifier];
	_value = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

- (void)setValue:(id<NSCoding,NSCopying>)value
{
	_value = value;
	if (value) {
		NSString *filePath = [folderPath() stringByAppendingPathComponent:self.identifier];
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
		[data writeToFile:filePath atomically:YES];
		_dataSize = data.length;
	}

	_lastAccessedDate = [NSDate date];
}

@end


@interface GXCache ()
@property (strong, nonatomic) NSMutableSet<NSString *> *keys;
@property (strong, nonatomic) NSMutableDictionary<NSString *, GXCacheNode *> *dictionary;
@property (strong, nonatomic) dispatch_queue_t queue;

@property (assign, nonatomic) NSUInteger usedCapacity;
@end

@implementation GXCache

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.queue = dispatch_queue_create("com.gx.cache", DISPATCH_QUEUE_CONCURRENT);
		self.keys = [NSMutableSet<NSString *> set];
		self.dictionary = [NSMutableDictionary<NSString *, GXCacheNode *> dictionary];
		
		self.capacity = 1024 * 1024 * 10;
		self.maximunCount = NSNotFound;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)setObject:(id<NSCoding, NSCopying>)object forKey:(NSString *)key
{
	if (!key.length) {
		return;
	}
	else if (!object) {
		[self removeObjectForKey:key];
		return;
	}
	
	__weak typeof(self) weakSelf = self;
	dispatch_barrier_async(self.queue, ^{
		if ([weakSelf.keys containsObject:key]) {
			GXCacheNode *node = weakSelf.dictionary[key];
			weakSelf.usedCapacity -= node.dataSize;
			node.value = object;
			weakSelf.usedCapacity += node.dataSize;
			[weakSelf cleanCacheIfNeed];
			return;
		}
		
		GXCacheNode *node = [[GXCacheNode alloc] init];
		node.value = object;
		weakSelf.usedCapacity += node.dataSize;
		weakSelf.dictionary[key] = node;
		[weakSelf.keys addObject:key];
		
		[weakSelf cleanCacheIfNeed];
	});
}

- (id<NSCoding, NSCopying>)objectForKey:(NSString *)key
{
	__block id<NSCoding, NSCopying> obj = nil;
	__weak typeof(self) weakSelf = self;
	dispatch_barrier_sync(self.queue, ^{
		if([weakSelf.keys containsObject:key]) {
			obj = weakSelf.dictionary[key].value;
			if (!obj) {
				[weakSelf.dictionary[key] restore];
				obj = weakSelf.dictionary[key].value;
			}
			weakSelf.dictionary[key].lastAccessedDate = [NSDate date];
		}
	});
	return obj;
}

- (void)removeObjectForKey:(NSString *)key
{
	__weak typeof(self) weakSelf = self;
	dispatch_barrier_async(self.queue, ^{
		weakSelf.usedCapacity -= weakSelf.dictionary[key].dataSize;
		[weakSelf.dictionary removeObjectForKey:key];
		[weakSelf.keys removeObject:key];
	});
}

- (NSSet<NSString *> *)allKeys
{
	__block NSSet<NSString *> * allKeys = nil;
	__weak typeof(self) weakSelf = self;
	dispatch_barrier_sync(self.queue, ^{
		allKeys = [weakSelf.keys copy];
	});
	return allKeys;
}

- (void)zap
{
	__weak typeof(self) weakSelf = self;
	dispatch_barrier_async(self.queue, ^{
		weakSelf.usedCapacity = 0;
		[weakSelf.dictionary removeAllObjects];
		[weakSelf.keys removeAllObjects];
	});
}

#pragma mark -

- (void)cleanCacheIfNeed
{
	if ([NSThread currentThread].isMainThread) {
		__weak typeof(self) weakSelf = self;
		dispatch_barrier_async(self.queue, ^{
			[weakSelf cleanCacheIfNeed];
		});
		return;
	}
	
	NSUInteger count = self.keys.count;
	if (count <= kSaveCountForNodeDuringCleanCache) {
		return;
	}
	
	if ((self.usedCapacity < self.capacity &&
		 !(count > self.maximunCount && self.maximunCount != NSNotFound))) {
		return;
	}
	
	NSMutableArray<NSString *> *sortedKeys = [[self.dictionary keysSortedByValueUsingComparator:^NSComparisonResult(GXCacheNode *leftNode, GXCacheNode *rightNode) {
		return [rightNode.lastAccessedDate compare:leftNode.lastAccessedDate];
	}] mutableCopy];
	
	NSMutableArray<NSString *> *removeKeys = [NSMutableArray array];
	NSUInteger reduceCapacity = 0;
	if (self.maximunCount < count && self.maximunCount != NSNotFound) {
		
		NSInteger needRemoveCount = count - self.maximunCount;
		NSInteger startIndex = count - needRemoveCount;
		[removeKeys addObjectsFromArray:[sortedKeys subarrayWithRange:NSMakeRange(startIndex, needRemoveCount)]];
		NSArray<GXCacheNode *> *willRemoveNodes = [self.dictionary objectsForKeys:removeKeys notFoundMarker:[GXCacheNode new]];
		
		reduceCapacity = [[willRemoveNodes valueForKeyPath:@"@sum.dataSize"] integerValue];
	}
	
	while (self.usedCapacity - reduceCapacity > self.capacity && sortedKeys.count > kSaveCountForNodeDuringCleanCache) {
		[removeKeys addObject:sortedKeys.lastObject];
		reduceCapacity += self.dictionary[sortedKeys.lastObject].dataSize;
		[sortedKeys removeLastObject];
	}
	
	if (!removeKeys.count) {
		return;
	}
	self.usedCapacity -= reduceCapacity;
	[self.dictionary removeObjectsForKeys:removeKeys];
	[self.keys minusSet:[NSSet setWithArray:removeKeys]];
}

#pragma mark - Notification

- (void)didReceivedMemoryWarning
{
	__weak typeof(self) weakSelf = self;
	dispatch_async(self.queue, ^{
		for (NSString *key in weakSelf.keys) {
			[weakSelf.dictionary[key] cleanMemory];
		}
	});
}

#pragma mark -

- (void)setMaximunCount:(NSInteger)maximunCount
{
	_maximunCount = MIN(MAX(kMinimumCount, maximunCount), NSNotFound);
	[self cleanCacheIfNeed];
}

@end
