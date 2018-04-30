//
//  GXCache.h
//  GXCache
//
//  Created by Green on 29/04/2018.
//  Copyright © 2018 Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXCache : NSObject
- (void)setObject:(id<NSCoding, NSCopying>)object forKey:(NSString *)key;
- (id<NSCoding, NSCopying>)objectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (NSSet<NSString *> *)allKeys;
@property (assign, nonatomic) NSUInteger capacity;
@property (assign, nonatomic) NSInteger maximunCount;
@property (readonly, getter=allKeys, nonatomic) NSSet<NSString *> *allKeys;
@end
