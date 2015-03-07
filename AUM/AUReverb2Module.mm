//
//  ReverbAUModule.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 31/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import "AUReverb2Module.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract fulfillment / Overrides
/////////////////////////////////////////////////////////////////////////
using namespace AUM;

const AudioComponentDescription AUReverb2Module::_auComponentDescription()
{
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Effect;
    desc.componentSubType       = kAudioUnitSubType_Reverb2;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    
    return desc;
}

//---------------------------------------------------------------------

void AUReverb2Module::_willInitializeAU()
{
    // Enforce our canonical format as per AUAudioModuleBase's instructions
    _setInputBusStreamFormat(0, AUM_kCanonicalStreamFormat);
    _setOutputBusStreamFormat(0, AUM_kCanonicalStreamFormat);

    auto _ = AUM::ErrorChecker([AUMAudioModuleException class]);
    UInt32 val = 0;
    _(AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Input, 0, &val, sizeof(val)),
      @"Error telling Reverb2 to not allocate buffers (AudioUnitSetProperty)");
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Parameters
/////////////////////////////////////////////////////////////////////////

AudioUnitParameterValue AUReverb2Module::dryWetMix()
{
    return _getParameter(kReverb2Param_DryWetMix);
}

//---------------------------------------------------------------------

void AUReverb2Module::dryWetMix(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_DryWetMix, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2Module::gain()
{
    return _getParameter(kReverb2Param_Gain);

}

//---------------------------------------------------------------------

void AUReverb2Module::gain(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_Gain, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2Module::minDelayTime()
{
    return _getParameter(kReverb2Param_MinDelayTime);
}

//---------------------------------------------------------------------

void AUReverb2Module::minDelayTime(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_MinDelayTime, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2Module::maxDelayTime()
{
    return _getParameter(kReverb2Param_MaxDelayTime);
}

//---------------------------------------------------------------------

void AUReverb2Module::maxDelayTime(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_MaxDelayTime, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2Module::decayTimeAt0Hz()
{
    return _getParameter(kReverb2Param_DecayTimeAt0Hz);
}

//---------------------------------------------------------------------

void AUReverb2Module::decayTimeAt0Hz(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_DecayTimeAt0Hz, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2Module::decayTimeAtNyquist()
{
    return _getParameter(kReverb2Param_DecayTimeAtNyquist);
}

void AUReverb2Module::decayTimeAtNyquist(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_DecayTimeAtNyquist, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2Module::AUReverb2Module::randomizeReflections()
{
    return _getParameter(kReverb2Param_RandomizeReflections);
}

void AUReverb2Module::randomizeReflections(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_RandomizeReflections, value);
}

//---------------------------------------------------------------------






