//
//  AUMExceptions.h
//  AUMLansingAudioBrains
//
//  Created by Hari Karam Singh on 16/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Base Class
/////////////////////////////////////////////////////////////////////////

@interface AUMException : NSException

+ (instancetype)exceptionWithFormat:(NSString *)format, ...;

@property (nonatomic) NSError *underlyingError;
@property (nonatomic) OSStatus OSStatus;

/// Coverts the 4 byte char into a string to give us a chance at understanding it's meaning. Doesn't always convert in which case the string will just be the number
@property (nonatomic, readonly) NSString *OSStatusAsString;

@end

/////////////////////////////////////////////////////////////////////////
#pragma mark - Subclasses
/////////////////////////////////////////////////////////////////////////

@interface AUMAudioSessionException : AUMException @end
@interface AUMAudioModuleException : AUMException @end
@interface AUMAudioFileIOException : AUMException @end



/////////////////////////////////////////////////////////////////////////
#pragma mark - Utility
/////////////////////////////////////////////////////////////////////////

#ifdef __cplusplus
namespace AUM {
    /** A functor to get an error handler shorthand which is set to throw a specific Objective-C class type. Only works in (Objective-)C++ code
     
     USAGE: 
     auto _ = AUM::ErrorChecker([AUMAudioModuleException class])
     
     _(someFuncWhichReturnsOSStatus(), @"Error calling some func");
     
     [[AVAudioSession sharedInstance] setActive:YES error:&err];
     _(err, @"Error initialising audio");
     
     */
    class ErrorChecker
    {
    private:
        Class _objcExceptionClass;
        
    public:
        ErrorChecker(Class objcExceptionClass) : _objcExceptionClass(objcExceptionClass) {
            // Check it's a legit
            if (not [_objcExceptionClass isSubclassOfClass:[AUMException class]]) {
                [NSException raise:NSInvalidArgumentException format:@"Class must be a subclass of AUMException!"];
            }
        };
        
        /// OSStatus error check
        void operator()(::OSStatus err, NSString *format, ...) {
            if (err != noErr) {
                NSLog(@"OSStatus: %li", (signed long)err);
                va_list args;
                va_start(args, format);
                NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
                AUMException *e = [_objcExceptionClass exceptionWithFormat:msg];
                va_end(args);
                e.OSStatus = err;
                @throw e;
            }
        }
        
        /// NSError error check (such as from AVAudioSession)
        void operator()(NSError *err, NSString *format, ...) {
            if (err != nil) {
                va_list args;
                va_start(args, format);
                AUMException *e = [_objcExceptionClass exceptionWithFormat:format, args];
                va_end(args);
                e.underlyingError = err;
                @throw e;
            }
        }
        
        
    };
}
#endif
