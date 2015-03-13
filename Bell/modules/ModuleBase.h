//
//  ModuleBase.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 23/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BellDefs.h"

namespace bell {
    namespace modules {
        
        /** Abstract class for our modules. Just to show devs how it works... */
        class ModuleBase
        {
        public:
            ModuleBase() {}
            virtual ~ModuleBase() {}   // prevent compiler default
            //        virtual OSStatus process(UInt32 numFrames, AudioBufferList *ioData);
            virtual OSStatus process(UInt32 nFrames, BellSample *L, BellSample *R) = 0;
            
        protected:
            /** Utility to create an ABL with canonical format without the buffers assigned.  Use it in "process" to wrap the data buffers in a shell. */
            inline static AudioBufferList *_createAudioBufferListStruct();
            inline static void _destroyAudioBufferListStruct(AudioBufferList *abl);
            
            inline static void _assignBuffersToAudioBufferList(AudioBufferList *ioABL, UInt32 nFrames, BellSample *L, BellSample *R);
            
        protected:
            /// We need to malloc this so do it on init rather than in the render function
            AudioBufferList *_audioBufferList;
            
        };
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////

AudioBufferList *bell::modules::ModuleBase::_createAudioBufferListStruct()
{
    AudioBufferList *abl;
    UInt32 nChannels = 2;
    abl = (AudioBufferList *)malloc(offsetof(AudioBufferList, mBuffers) + nChannels * sizeof(AudioBuffer));
    
    return abl;
}

//---------------------------------------------------------------------

void bell::modules::ModuleBase::_destroyAudioBufferListStruct(AudioBufferList *abl)
{
    free(abl);
}

//---------------------------------------------------------------------

void bell::modules::ModuleBase::_assignBuffersToAudioBufferList(AudioBufferList *ioABL, UInt32 nFrames, BellSample *L, BellSample *R)
{
    UInt32 byteSize = nFrames * kBellCanonicalStreamFormat.mBytesPerFrame;
    
    ioABL->mNumberBuffers = 2;
    ioABL->mBuffers[0].mNumberChannels = 1;   // for this single buffer
    ioABL->mBuffers[1].mNumberChannels = 1;
    
    ioABL->mBuffers[0].mDataByteSize = byteSize;
    ioABL->mBuffers[1].mDataByteSize = byteSize;
    
    ioABL->mBuffers[0].mData = (void *)L;
    ioABL->mBuffers[1].mData = (void *)R;
}