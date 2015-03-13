//
//  FileRecorder.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 23/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BellAudioFile.h"
#import "ModuleBase.h"
#include "AtomicTypes.h"

namespace bell {
    namespace modules {
        class FileRecorder : public ModuleBase
        {
        public:
            FileRecorder();
            ~FileRecorder();
            
            void setAudioFile(BellAudioFile *audioFile);
            
            /** Inline in case we want them in the RCB */
            inline void record();
            inline void stop();
            
            /** Call this in the RCB regardless of whether recording is on or off.  This is handled internally */
            inline OSStatus process(UInt32 nFrames, BellSample *L, BellSample *R);
            
        private:
            AudioBufferList *_audioBufferList;
            BellAudioFile *_audioFile;
            AtomicBool _isRecording;
        };
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////
using namespace bell::modules;

OSStatus FileRecorder::process(UInt32 nFrames, BellSample *L, BellSample *R)
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

void FileRecorder::record()
{
    assert(_audioFile);
    _isRecording = YES;
}

//---------------------------------------------------------------------

void FileRecorder::stop()
{
    _isRecording = NO;
}
