//
//  ViewController.m
//  GXCache
//
//  Created by Green on 29/04/2018.
//  Copyright © 2018 Green. All rights reserved.
//

#import "ViewController.h"
#import "GXCache.h"

@interface ViewController ()
@property (strong, nonatomic) GXCache *cache;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.cache = [[GXCache alloc] init];
//	self.cache.capacity = 430;
	self.cache.maximunCount = 1;
	
	[self.cache setObject:@{@"KKBOX":@"Zonble is iOS/Mac Lead",
							@"UtaPass":@"Abe is so busy every",
							@"KKTIX": @"Sr. engineers are leaving"
							} forKey:@"a"];
	
//	NSLog(@"set 2");
//	[self.cache setObject:@{@"KKBOX":@"Zonble is iOS/Mac Lead",
//							@"UtaPass":@"Abe is so busy every",
//							@"KKTIX": @"Sr. engineers are leaving",
//							@"Liyao": @"Awesome guy, want to change the world"
//							} forKey:@"b"];
//	NSLog(@"end");
	NSLog(@"%@", [self.cache objectForKey:@"a"]);
//	NSLog(@"%@", self.cache.allKeys);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"%@", [self.cache objectForKey:@"a"]);
}


@end
