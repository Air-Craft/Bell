//
//  AUMSession.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 17/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


/////////////////////////////////////////////////////////////////////////
#pragma mark - Main Class
/////////////////////////////////////////////////////////////////////////

@interface AUMSession : NSObject

@property (nonatomic, readonly) NSTimeInterval sampleRate;
@property (nonatomic, readonly) NSTimeInterval ioBufferDuration;

/** Defaults to NO.  Set to yes to enable.  Can be updated on the fly */
@property (atomic) BOOL microphoneEnabled;

/** 
 Uses defaults AVAudioSessionCategoryPlayAndRecord / AVAudioSessionCategoryOptionDuckOthers / 44.1kHz / 0.01s (IOBuffer) / AUM_kCanonicalStreamFormat.  Note the actualy IOBuffer size and sample rate may differ (esp on simulator) so be sure to check afterwards (standard CoreAudio procedure).  The session is also set to "active" on init.
 @override
 @throws AUMException if audio engine fails to initialise for any reasons
 */
- (instancetype)init;

/** 
 Specify your own params
 @throws AUMException @see init 
 */
- (instancetype)initWithCategory:(NSString * const)category
                 categoryOptions:(AVAudioSessionCategoryOptions)categoryOptions
             preferredSampleRate:(NSTimeInterval)sampleRate
       preferredIOBufferDuration:(NSTimeInterval)ioBufferDuration
                    streamFormat:(AudioStreamBasicDescription)streamFormat
                  renderCallback:(AURenderCallback)renderCallbackFunc
            renderCallbackObject:(void *)renderCallbackObject
                     andActivate:(BOOL)doSetActive;


/** 
 @throws AUMException
 */
- (void)startAudio;

/**
 @throws AUMException
 */
- (void)stopAudio;

@end
