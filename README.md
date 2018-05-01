# GXCache

GXCache is a lightweight cache component. It releases the data cache in memonry when your App receives memory warning, and lazy-loading when you access your value next time. 

## Features

* [x] Thread-safe.   
* [x] Support Objective-C NSCoding and NSCopying.   
* [ ] Support Swift. 

## How GXCache works

GXCache will clean the cache folder when you first time cache data for each process. Write data into disk when set data into cache and observer `UIApplicationDidReceiveMemonryWarningNotification` to release data in memory. Lazy-loading will work if there occurred memory warning.

# How to use

You can find sample with the testcase [GXCacheTests.m](https://github.com/greenchiu/GXCache/blob/master/GXCacheTests/GXCacheTests.m)

# License

Use this component in your apps? Let me know!

Copyright (c) 2018  Green Chiu, http://greenchiu.github.com/ Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
