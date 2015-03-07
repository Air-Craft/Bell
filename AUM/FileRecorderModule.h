//
//  FileRecorderModule.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 23/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUMAudioFile.h"
#import "AudioModuleBase.h"
#include "AtomicTypes.h"

namespace AUM {
    
    class FileRecorderModule : public AudioModuleBase
    {
    public:
        FileRecorderModule();
        ~FileRecorderModule();
        
        void setAudioFile(AUMAudioFile *audioFile);
        
        /** Inline in case we want them in the RCB */
        inline void record();
        inline void stop();
        
        /** Call this in the RCB regardless of whether recording is on or off.  This is handled internally */
        inline OSStatus process(UInt32 nFrames, AUM_Sample *L, AUM_Sample *R);
        
    private:
        AudioBufferList *_audioBufferList;
        AUMAudioFile *_audioFile;
        AtomicBool _isRecording;
    };
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////
using namespace AUM;

OSStatus FileRecorderModule::process(UInt32 nFrames, AUM_Sample *L, AUM_Sample *R)
{
    // Assign buffers to the ABL
    // NO! Need to set the data
    _assignBuffersToAudioBufferList(_audioBufferList, nFrames, L, R);
    
    // Only write if we're actually recording
    OSStatus res = noErr;
    if (_isRecording) {
        res = ExtAudioFileWriteAsync(_audioFile->fileRef, nFrames, _audioBufferList);
    }
    return res;
}

//---------------------------------------------------------------------

void FileRecorderModule::record()
{
    assert(_audioFile);
    _isRecording = YES;
}

//---------------------------------------------------------------------

void FileRecorderModule::stop()
{
    _isRecording = NO;
}
