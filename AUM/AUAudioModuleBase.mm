//
//  AudioUnitRenderer.cpp
//  AUMLansingAudioBrains
//
//  Created by Hari Karam Singh on 15/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#import "AUAudioModuleBase.h"
#import "AUMExceptions.h"
#import "AUMUtils.h"

AUM::AUAudioModuleBase::AUAudioModuleBase()
{
    // Allocate the wrapper for the render buffers
    // Look at the struct to see where we get this from.  2 is the number of channels.  Variable channels is why this needs to be a malloc'ed pointer
    _audioBufferList = _createAudioBufferListStruct();

    
    _audioTimeStamp = {0};
    _audioTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    _audioTimeStamp.mSampleTime = 0;
}

//---------------------------------------------------------------------

AUM::AUAudioModuleBase::~AUAudioModuleBase()
{
    _destroyAudioBufferListStruct(_audioBufferList);
}

//---------------------------------------------------------------------

void AUM::AUAudioModuleBase::initialize()
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    
    // Load the AU spec'ed by the subclass
    AudioComponentDescription desc = this->_auComponentDescription();
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    _(AudioComponentInstanceNew(comp, &_audioUnit), @"Error creating the Audio Unit's component");
    
    // Does this type have an input?
    _hasInput = (   desc.componentType == kAudioUnitType_Effect
                 || desc.componentType == kAudioUnitType_Mixer
                 || desc.componentType == kAudioUnitType_Panner
                 || desc.componentType == kAudioUnitType_MusicEffect
                 || desc.componentType == kAudioUnitType_OfflineEffect
                 || desc.componentType == kAudioUnitType_FormatConverter
                 );
    
    // If an effect, attach the RCB to feed it's input
    if (_hasInput) {
        AURenderCallbackStruct rcbStruct = {
            .inputProc = &_inputRCB,
            .inputProcRefCon = this
        };
        _(AudioUnitSetProperty(_audioUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &rcbStruct,
                               sizeof(rcbStruct)),
          @"Error attaching input RCB onto Effect AU");
    }
    

    // Initialize sequence with hooks
    _willInitializeAU();
    _(AudioUnitInitialize(_audioUnit), @"Error initialising the Audio Unit");
     _didInitializeAU();
}

//---------------------------------------------------------------------

void AUM::AUAudioModuleBase::_setInputBusStreamFormat(UInt32 busNum, AudioStreamBasicDescription format)
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);

    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_StreamFormat,
                           kAudioUnitScope_Input,
                           busNum,
                           &format,
                           sizeof(format)),
      @"Error setting format on Input Bus %i", busNum);
}

//---------------------------------------------------------------------

void AUM::AUAudioModuleBase::_setOutputBusStreamFormat(UInt32 busNum, AudioStreamBasicDescription format)
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    
    _(AudioUnitSetProperty(_audioUnit,
                           kAudioUnitProperty_StreamFormat,
                           kAudioUnitScope_Output,
                           busNum,
                           &format,
                           sizeof(format)),
      @"Error setting format on Output Bus %i", busNum);
}

//---------------------------------------------------------------------

void AUM::AUAudioModuleBase::_setParameter(AudioUnitParameterID paramId, AudioUnitParameterValue paramValue, AudioUnitScope scope, AudioUnitElement element)
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    
    _(AudioUnitSetParameter(_audioUnit,
                            paramId,
                            scope,
                            element,
                            paramValue,
                            0),     // always 0
      @"Error setting parameter on AudioUnit");
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUM::AUAudioModuleBase::_getParameter(AudioUnitParameterID paramId, AudioUnitScope scope, AudioUnitElement element)
{
    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    
    AudioUnitParameterValue value;
    
    _(AudioUnitGetParameter(_audioUnit,
                          paramId,
                          scope,
                          element, &value),
      @"Error getting parameter from AudioUnit");
    
    return value;
}




