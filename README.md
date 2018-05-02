# GXCache

A lightweight cache component.

[![Build Status](https://travis-ci.org/greenchiu/GXCache.svg?branch=master)](https://travis-ci.org/greenchiu/GXCache)
[![Support](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://www.apple.com/tw/ios)&nbsp;
[![Support](https://img.shields.io/badge/Language-ObjC-blue.svg)](https://www.apple.com/tw/ios)&nbsp;

GXCache is a lightweight cache component. It releases the data cache in memonry when your App receives memory warning, and lazy-loading when you access your value next time. 

## Features

* [x] Thread-safe.   
* [x] Support Objective-C NSCoding and NSCopying.   
* [ ] Support Swift. 

## How GXCache works

GXCache will clean the cache folder when you first time cache data for each process. Write data into disk when set data into cache and observer `UIApplicationDidReceiveMemonryWarningNotification` to release data in memory. Lazy-loading will work if there occurred memory warning.

## How to use

You can find sample with the testcase [GXCacheTests.m](https://github.com/greenchiu/GXCache/blob/master/GXCacheTests/GXCacheTests.m)

# Installation

Add files `GXCache .h and .m` into your project manually, they are under folder `sources`.

# License

Use this component in your apps? Let me know!

Copyright (c) 2018  ChihChiang-Chiu (Green), https://medium.com/@greenchiu1986 Licensed under the MIT license.
