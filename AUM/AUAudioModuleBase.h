//
//  AudioUnitRenderer.h
//  AUMLansingAudioBrains
//
//  Created by Hari Karam Singh on 15/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#ifndef __Marshmallows__AudioUnitRenderer__
#define __Marshmallows__AudioUnitRenderer__

 #import <CoreAudio/CoreAudioTypes.h>
#import "AudioModuleBase.h"
#import "AUMDefs.h"
#import "AUMExceptions.h"

namespace AUM {
    
    /** 
     Base class for wrapped AUs which get rendered in a single RCB
     
     STREAM FORMATS:
     - We enforce our Canonical type in this framework (see AUMDefs.h). But since we have no way of knowing the bus count ahead of time (it can be varied at any time for some AUs), we leave it to the subclass to enforce the stream format!  We do give a couple convenience methods here though.  Use the `_willInitialize()` hook
     
     @abstract 
     
     @todo Our input RCB hack may need to be on a per subclass basis.  Otherwise for multiple input buses, like AUMixer, you might need 1 buffer pair per bus. We're trying not to have bus a setting in the subclass as we're trying not to make Base too smart and get away from core audio too much.
     */
    class AUAudioModuleBase : public AudioModuleBase
    {
    private:
        
        /** Effects units and things with input  */
        static OSStatus _inputRCB(	void *							inRefCon,
                                  AudioUnitRenderActionFlags *	ioActionFlags,
                                  const AudioTimeStamp *			inTimeStamp,
                                  UInt32							inBusNumber,
                                  UInt32							inNumberFrames,
                                  AudioBufferList *				ioData) {
            // Just a passthrough of the render data...
            AUAudioModuleBase *me = (AUAudioModuleBase *)inRefCon;
            
            ioData->mBuffers[0].mData = me->_inputBuffL;
            ioData->mBuffers[1].mData = me->_inputBuffR;
            
            return noErr;
        }
        
        
        
    public:
        AUAudioModuleBase();
        ~AUAudioModuleBase();
    
        // @TODO Copy and assignment constructors (Rule of 3)
        
        /// Build and initialise the AU.
        void initialize();

        /** We're enforcing a simple, single workign format here  */
        inline OSStatus process(UInt32 nFrames, AUM_Sample *L, AUM_Sample *R);

//        /// Sometimes we have it already from the RCB and just need to fill it
    private:
        /** Keep this separate in case we change our mind again */
        inline OSStatus _process(UInt32 nFrames, AudioBufferList *audioBufferList);
    public:
        
        /// In case we make a pass and don't use this particular AU then we need to keep it's time tracker in sync. In other words, on each pass you MUST call wither render(...) or this
        inline void skipFrames(UInt32 nFrames);
        
    // virtuals
    protected:
        /// Must override to define the AU attributes
        virtual const AudioComponentDescription _auComponentDescription() = 0;
        
        /// Optional init hooks.  Usually needed to set stream formats on the i/o buses (about which this superclass has no knowlege as they are specific to each AU).  "will" is after creating the new instance but before the AudioUnitInitialize
        virtual void _willInitializeAU() {};
        virtual void _didInitializeAU() {};
        
    // ivars & helper methods
    protected:
        /// Reference to the AU
        AudioUnit _audioUnit;
        
        /// The time in frames for the next render
        AudioTimeStamp _audioTimeStamp;
        
        /** Convenience methods for interacting with the buses.   See class notes for important into about stream formats */
        void _setInputBusStreamFormat(UInt32 busNum, AudioStreamBasicDescription format);
        void _setOutputBusStreamFormat(UInt32 busNum, AudioStreamBasicDescription format);
        
        /** 
         Convenience getters/setters. Default to Global scope, element 0
         @throws AUMAudioModuleException on error 
         */
        void _setParameter(AudioUnitParameterID paramId, AudioUnitParameterValue paramValue, AudioUnitScope scope = kAudioUnitScope_Global, AudioUnitElement element = 0);
        
        AudioUnitParameterValue _getParameter(AudioUnitParameterID paramId, AudioUnitScope scope = kAudioUnitScope_Global, AudioUnitElement element = 0);
        
    private:
        void *_inputBuffL;
        void *_inputBuffR;
        bool _hasInput;     // Flag set on init to determine whether we pre-render with the input RCB
    };
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////

inline OSStatus AUM::AUAudioModuleBase::process(UInt32 nFrames, AUM_Sample *L, AUM_Sample *R)
{
    _assignBuffersToAudioBufferList(_audioBufferList, nFrames, L, R);
    return _process(nFrames, _audioBufferList);
}

//---------------------------------------------------------------------

inline OSStatus AUM::AUAudioModuleBase::_process(UInt32 nFrames, AudioBufferList *audioBufferList)
{
    AudioUnitRenderActionFlags ioActionFlags = 0;
    
    OSStatus err = noErr;
    
    // Render AU
    // Only prerender if an effect (generators dont need it)
    if (_hasInput) {
        ioActionFlags = kAudioUnitRenderAction_PreRender;
        
        // Set the buffers to the ones used in the RCB
        _inputBuffL = audioBufferList->mBuffers[0].mData;
        _inputBuffR = audioBufferList->mBuffers[1].mData;
        
        err = AudioUnitRender(_audioUnit,
                              &ioActionFlags,
                              &_audioTimeStamp,
                              0,
                              (UInt32)nFrames,
                              audioBufferList
                              );
    }
    if (err == noErr) {
        ioActionFlags = kAudioUnitRenderAction_PostRender;
        err = AudioUnitRender(_audioUnit,
                              &ioActionFlags,
                              &_audioTimeStamp,
                              0,
                              (UInt32)nFrames,
                              audioBufferList
                              );
    }

    // Be sure to inc the counter for the AU
    _audioTimeStamp.mSampleTime += nFrames;
    
    return err;
}

//---------------------------------------------------------------------

inline void AUM::AUAudioModuleBase::skipFrames(UInt32 nFrames)
{
    _audioTimeStamp.mSampleTime += nFrames;
}


#endif /* defined(__Marshmallows__AudioUnitRenderer__) */
