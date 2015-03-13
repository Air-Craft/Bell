//
//  Bell.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 17/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "Bell.h"
#import "BellDefs.h"
#import "BellExceptions.h"
#import "AtomicTypes.h"


typedef struct {
    AudioUnit remoteIOUnit;
    bell::AtomicBool micEnabled;
    AURenderCallback wrappedRCB;
    void *wrappedInRefCon;
} _BellSessionInRefConWrapper;


/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

OSStatus _BellSessionRCBWrapper(void *inRefCon,
                               AudioUnitRenderActionFlags *	ioActionFlags,
                               const AudioTimeStamp *		inTimeStamp,
                               UInt32						inBusNumber,
                               UInt32						inNumberFrames,
                               AudioBufferList *			ioData)
{
    OSStatus err = noErr;
    _BellSessionInRefConWrapper *me = (_BellSessionInRefConWrapper *)inRefCon;
    
    // Grab the mic data first for convenience
    if (me->micEnabled) {
        UInt32 micBus = 1;
        err = AudioUnitRender(me->remoteIOUnit, ioActionFlags, inTimeStamp, micBus, inNumberFrames, ioData);
        // Handle err?
    } else {
        // Otherwise zero it out (??)
        vDSP_vclr((float *)ioData->mBuffers[0].mData, 1, inNumberFrames);
        vDSP_vclr((float *)ioData->mBuffers[1].mData, 1, inNumberFrames);
    }
    
    // Now call the wrapped RCB
    err = me->wrappedRCB(me->wrappedInRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    
    return err;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@interface BellSession ()
{
    _BellSessionInRefConWrapper _inRefConWrap;
}

/**  Make these RW so we can set them internal and leverage the atomicity */
@property (atomic, readwrite) NSTimeInterval sampleRate;
@property (atomic, readwrite) NSTimeInterval ioBufferDuration;

@end

/////////////////////////////////////////////////////////////////////////
#pragma mark -
/////////////////////////////////////////////////////////////////////////

@implementation BellSession
{
    AudioUnit _remoteIOUnit;
}



- (id)init
{
    self = [super init];
    if (self) {
        [NSException raise:NSGenericException format:@"Use the designated init please!"];
    }
    return self;
}

//---------------------------------------------------------------------

- (instancetype)initWithCategory:(NSString * const)category
                 categoryOptions:(AVAudioSessionCategoryOptions)categoryOptions
             preferredSampleRate:(NSTimeInterval)sampleRate
       preferredIOBufferDuration:(NSTimeInterval)ioBufferDuration
                    streamFormat:(AudioStreamBasicDescription)streamFormat
                  renderCallback:(AURenderCallback)renderCallbackFunc
            renderCallbackObject:(void *)renderCallbackObject
                     andActivate:(BOOL)doSetActive
{
    self = [super init];
    if (self) {
        auto _ = bell::ErrorChecker([BellAudioSessionException class]);
        NSError *err;
        
        AudioStreamBasicDescription asbd = streamFormat;
        asbd.mSampleRate = sampleRate;         // need to set this explicitly

        /////////////////////////////////////////
        // SETUP AUDIO SESSION
        /////////////////////////////////////////
        
        // Initialise the session...
        [[AVAudioSession sharedInstance] setCategory:category error:&err];
        _(err, @"Error setting Category on AVAudioSession");
        
        [[AVAudioSession sharedInstance] setActive:doSetActive error:&err];
        _(err, @"Error setting Active on AVAudioSession");
        
        [[AVAudioSession sharedInstance] setPreferredSampleRate:sampleRate error:&err];
        _(err, @"Error setting Sample Rate on AVAudioSession");
        
        // This should make it 512 frames in a render
        [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:ioBufferDuration error:&err];
        _(err, @"Error setting Buffer Duration on AVAudioSession");
        
        
        /////////////////////////////////////////
        // CREATE REMOTE IO UNIT
        /////////////////////////////////////////
        
        // Setup a RemoteIO AU
        AudioComponentDescription inputDescription = {0};
        inputDescription.componentType = kAudioUnitType_Output;
        inputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
        inputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        AudioComponent inputComponent = AudioComponentFindNext(NULL, &inputDescription);
        _(AudioComponentInstanceNew(inputComponent, &_remoteIOUnit),
          @"Error creating RemoteIO instance");
        
        /////////////////////////////////////////
        // OUTPUT ENABLE & STREAM FORMAT
        /////////////////////////////////////////
        
        // Uncomment to enable mic input
        UInt32 onOff = 1;
        // Enabled by default I believe
//        _(AudioUnitSetProperty(_remoteIOUnit,
//                               kAudioOutputUnitProperty_EnableIO,
//                               kAudioUnitScope_Output,
//                               0,
//                               &onOff,
//                               sizeof(onOff)),
//          @"AudioUnitSetProperty error when activated RemoteIO output.");
        

        
        // Set the format to our canonical
        // @TODO make param
        _(AudioUnitSetProperty(_remoteIOUnit,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Input,
                               0,
                               &asbd,
                               sizeof(asbd)),
          @"Error setting Stream Format on the RemoteIO output");
        
        
        /////////////////////////////////////////
        // MICROPHONE ENABLE  & FORMAT
        /////////////////////////////////////////
        
        // Uncomment to enable mic input
        _(AudioUnitSetProperty(_remoteIOUnit,
                               kAudioOutputUnitProperty_EnableIO,
                               kAudioUnitScope_Input,
                               1,
                               &onOff,
                               sizeof(onOff)),
          @"AudioUnitSetProperty error when updating mic state.");
        
        
        _(AudioUnitSetProperty(_remoteIOUnit,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Output,
                               1,
                               &asbd,
                               sizeof(asbd)),
          @"Error setting Stream Format on the RemoteIO input");
        
//
        /////////////////////////////////////////
        // ATTACH OUR RCB
        /////////////////////////////////////////
        
        // We wrap the provided RCB in our own to enable grabbing mic data automagically...
        // First setup the wrapping inRefCon object and point to to the real RCB/inRefCon
        // Setup the wrapping RCB object (inRefCon) point to the actual details as well as setting out mic flag
        _inRefConWrap.micEnabled = true;
        _inRefConWrap.remoteIOUnit = _remoteIOUnit;
        _inRefConWrap.wrappedRCB = renderCallbackFunc;
        _inRefConWrap.wrappedInRefCon = renderCallbackObject;
        
        // Attach our wrapping render callback
        AURenderCallbackStruct rcbStruct;
        rcbStruct.inputProc = _BellSessionRCBWrapper;
        rcbStruct.inputProcRefCon = &_inRefConWrap;
        
        _(AudioUnitSetProperty(_remoteIOUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &rcbStruct,
                               sizeof(rcbStruct)),
          @"Error setting the Render Callback on the RemoteIO unit");
        
        // Initialise
        _(AudioUnitInitialize(_remoteIOUnit), @"Error initialising the RemoteIO unit");
        
    } // end if (self)
    
    return self;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

/** The _micEnabled property is atomic so we can use it in the RCB, hence the accessors */
- (BOOL)microphoneEnabled { return _inRefConWrap.micEnabled; }

- (void)setMicrophoneEnabled:(BOOL)microphoneEnabled {
    _inRefConWrap.micEnabled = microphoneEnabled;
}

//---------------------------------------------------------------------

- (NSTimeInterval)sampleRate
{
    return [[AVAudioSession sharedInstance] sampleRate];
}

//---------------------------------------------------------------------

- (NSTimeInterval)ioBufferDuration
{
    return [[AVAudioSession sharedInstance] IOBufferDuration];
}

//---------------------------------------------------------------------


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods
/////////////////////////////////////////////////////////////////////////

- (void)startAudio
{
    auto _ = bell::ErrorChecker([BellAudioSessionException class]);
    _(AudioOutputUnitStart(_remoteIOUnit), @"Error starting the RemoteIO audio.");
}

//---------------------------------------------------------------------

- (void)stopAudio
{
    auto _ = bell::ErrorChecker([BellAudioSessionException class]);
    _(AudioOutputUnitStop(_remoteIOUnit), @"Error stoping the RemoteIO audio");
}

@end
