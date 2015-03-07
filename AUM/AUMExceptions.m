 //
//  AUMExceptions.m
//  AUMLansingAudioBrains
//
//  Created by Hari Karam Singh on 16/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#import "AUMExceptions.h"

@implementation AUMException

/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

+ (instancetype)exceptionWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [NSString stringWithFormat:format, args];
    va_end(args);

    return [[self alloc] initWithName:NSStringFromClass([self class])
                               reason:reason
                             userInfo:nil];
}

//---------------------------------------------------------------------

/// Disable normal initialiser
+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
    [NSException raise:NSInvalidArgumentException format:@"Use exceptionWithReason. Name is obsolete here"];
    return nil;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

/**
 We use subclasses in favour over name so this doesn't really matter
 @override
 */
- (NSString *)name { return NSStringFromClass([self class]); }

//---------------------------------------------------------------------

- (NSString *)OSStatusAsString
{
    char str[10]="";
    OSStatus error = _OSStatus;
    
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else {
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    }
    
    return [NSString stringWithUTF8String:str];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Debug
/////////////////////////////////////////////////////////////////////////

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \"%@\"\nOSStatus: %@\nNSError: %@", NSStringFromClass([self class]), self.reason, self.OSStatusAsString, self.underlyingError];
}

@end

/////////////////////////////////////////////////////////////////////////
#pragma mark - Subclasses
/////////////////////////////////////////////////////////////////////////
@implementation AUMAudioSessionException @end
@implementation AUMAudioModuleException @end
@implementation AUMAudioFileIOException @end

