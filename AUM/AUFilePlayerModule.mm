//
//  AUFilePlayerRenderer.cpp
//  AUMLansingAudioBrains
//
//  Created by Hari Karam Singh on 15/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#import "AUFilePlayerModule.h"
#import "AUMExceptions.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract fulfillment / Overrides
/////////////////////////////////////////////////////////////////////////

const AudioComponentDescription AUM::AUFilePlayerModule::_auComponentDescription()
{
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Generator;
    desc.componentSubType       = kAudioUnitSubType_AudioFilePlayer;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    
    return desc;
};

//---------------------------------------------------------------------

void AUM::AUFilePlayerModule::_willInitializeAU()
{
    // Enforce our canonical format as per AUAudioModuleBase's instructions
    _setOutputBusStreamFormat(0, AUM_kCanonicalStreamFormat);    
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Publics
/////////////////////////////////////////////////////////////////////////

void AUM::AUFilePlayerModule::loadAudioFile(AUMAudioFile *audioFile)
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    
    // Check the stream format matches out canonical
    const AudioStreamBasicDescription asbd = audioFile.clientStreamFormat;
    if (0 != memcmp(&asbd, &AUM_kCanonicalStreamFormat, sizeof(AudioStreamBasicDescription))) {
        @throw [AUMAudioModuleException exceptionWithFormat:@"AudioFile client stream format must match Canonical."];
    }
    
    _audioFile = audioFile;

    // Get the AudioID
    AudioFileID audioFileId;
    UInt32 dataSize = sizeof(AudioFileID);
    ExtAudioFileGetProperty(audioFile->fileRef, kExtAudioFileProperty_AudioFile, &dataSize, &audioFileId);
    
    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_ScheduledFileIDs,
                           kAudioUnitScope_Global,
                           0,
                           &audioFileId,
                           sizeof(audioFileId)),
      @"Error setting the output Stream Format for the audio file reader");
}

//---------------------------------------------------------------------

void AUM::AUFilePlayerModule::play()
{
    playFromFrame(0);
}

//---------------------------------------------------------------------

void AUM::AUFilePlayerModule::playFromTime(NSTimeInterval startTime)
{
    // Only works for now files types with a fixed sample rate (otherwise there is a LOT more work required)
    assert(_audioFile.fileStreamFormat.mSampleRate);
    UInt32 startFrame = startTime * _audioFile.fileStreamFormat.mSampleRate;
    playFromFrame(startFrame);
}

//---------------------------------------------------------------------

void AUM::AUFilePlayerModule::playFromFrame(UInt32 startFrame)
{
    assert(startFrame < _audioFile.lengthInFrames);
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);

    // Keep track for later playhead functions
    _startFrame = startFrame;
    
    // Get the AudioID
    AudioFileID audioFileId;
    UInt32 dataSize = sizeof(AudioFileID);
    ExtAudioFileGetProperty(_audioFile->fileRef, kExtAudioFileProperty_AudioFile, &dataSize, &audioFileId);
    
    // Non-zero start time defines the loop start time too.  We want the whole thing to loop, so define two schedules, one from startFrame to play once and then the other to loop the whole thing
   
    /////////////////////////////////////////
    // PRE-AMBLE
    /////////////////////////////////////////
    
    // Tell it to play the whole file with optional looping...
    // more details: https://developer.apple.com/library/ios/qa/qa1786/_index.html
    ScheduledAudioFileRegion playRegion;
    playRegion.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    playRegion.mTimeStamp.mSampleTime = 0;
    playRegion.mCompletionProc = NULL;
    playRegion.mCompletionProcUserData = NULL;
    playRegion.mAudioFile = audioFileId;
    playRegion.mLoopCount = 0;
    playRegion.mStartFrame = startFrame;
    playRegion.mFramesToPlay = UInt32(-1);  // i.e. all of it
    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_ScheduledFileRegion,
                           kAudioUnitScope_Global,
                           0,
                           &playRegion,
                           sizeof(playRegion)),
      @"Error setting Audio File Region on the FilePlayer AU");
 
 
    /////////////////////////////////////////
    // LOOP
    /////////////////////////////////////////
    
    playRegion.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    playRegion.mTimeStamp.mSampleTime = _audioFile.lengthInFrames - startFrame;
    playRegion.mCompletionProc = NULL;
    playRegion.mCompletionProcUserData = NULL;
    playRegion.mAudioFile = audioFileId;
    playRegion.mLoopCount = UInt32(-1);
    playRegion.mStartFrame = 0;
    playRegion.mFramesToPlay = UInt32(-1);  // i.e. all of it
    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_ScheduledFileRegion,
                           kAudioUnitScope_Global,
                           0,
                           &playRegion,
                           sizeof(playRegion)),
      @"Error setting Audio File Region on the FilePlayer AU");
    
    
    /////////////////////////////////////////
    // PRIME AND PLAY
    /////////////////////////////////////////
    
    // "Prime it" - Pre-read a certain number of frames synchronously now
    UInt32 primeFrames = 0; // use default value (0x10000)
    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_ScheduledFilePrime,
                           kAudioUnitScope_Global,
                           0,
                           &primeFrames,
                           sizeof(primeFrames)),
      @"Error priming FilePlayer AU");
    
    // Finally for goodness sake...play...now!
    // set start time on next render cycle
    AudioTimeStamp startTime;
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1; // start immediately
    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_ScheduleStartTimeStamp,
                           kAudioUnitScope_Global,
                           0,
                           &startTime,
                           sizeof(startTime)),
      @"Error setting start time on File Player AU");
}

//---------------------------------------------------------------------

void AUM::AUFilePlayerModule::stop()
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);

    _(AudioUnitReset(_audioUnit,
                     kAudioUnitScope_Global,
                     0), @"Could not reset FilePlayer AU");
}

//---------------------------------------------------------------------

Float64 AUM::AUFilePlayerModule::playheadFrame()
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    
    // Query the playhed time
    AudioTimeStamp ts;
    UInt32 size = sizeof(ts);
    _(AudioUnitGetProperty(_audioUnit, kAudioUnitProperty_CurrentPlayTime,
                           kAudioUnitScope_Global, 0, &ts, &size),
      @"Error querying kAudioUnitProperty_CurrentPlayTime");

    // modf isn't like % exactly.  It just splits a single value into frac/int.  You need to remultiply to get back the remainder
    Float64 div = _audioFile.lengthInFrames;
    Float64 dum;
    Float64 frac = ::modf((ts.mSampleTime + _startFrame)/div, &dum) * div;
    
    return frac;
}

//---------------------------------------------------------------------

NSTimeInterval AUM::AUFilePlayerModule::playheadTime()
{
    return playheadFrame() / AUM_kCanonicalStreamFormat.mSampleRate;
}

//---------------------------------------------------------------------


