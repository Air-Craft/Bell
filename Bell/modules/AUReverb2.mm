//
//  ReverbAUModule.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 31/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import "AUReverb2.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract fulfillment / Overrides
/////////////////////////////////////////////////////////////////////////
using namespace bell::modules;

const AudioComponentDescription AUReverb2::_auComponentDescription()
{
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Effect;
    desc.componentSubType       = kAudioUnitSubType_Reverb2;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    
    return desc;
}

//---------------------------------------------------------------------

void AUReverb2::_willInitializeAU()
{
    // Enforce our canonical format as per AUModuleBase's instructions
    _setInputBusStreamFormat(0, kBellCanonicalStreamFormat);
    _setOutputBusStreamFormat(0, kBellCanonicalStreamFormat);

    auto _ = bell::ErrorChecker([BellAudioModuleException class]);
    UInt32 val = 0;
    _(AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Input, 0, &val, sizeof(val)),
      @"Error telling Reverb2 to not allocate buffers (AudioUnitSetProperty)");
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Parameters
/////////////////////////////////////////////////////////////////////////

AudioUnitParameterValue AUReverb2::dryWetMix()
{
    return _getParameter(kReverb2Param_DryWetMix);
}

//---------------------------------------------------------------------

void AUReverb2::dryWetMix(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_DryWetMix, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2::gain()
{
    return _getParameter(kReverb2Param_Gain);

}

//---------------------------------------------------------------------

void AUReverb2::gain(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_Gain, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2::minDelayTime()
{
    return _getParameter(kReverb2Param_MinDelayTime);
}

//---------------------------------------------------------------------

void AUReverb2::minDelayTime(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_MinDelayTime, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2::maxDelayTime()
{
    return _getParameter(kReverb2Param_MaxDelayTime);
}

//---------------------------------------------------------------------

void AUReverb2::maxDelayTime(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_MaxDelayTime, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2::decayTimeAt0Hz()
{
    return _getParameter(kReverb2Param_DecayTimeAt0Hz);
}

//---------------------------------------------------------------------

void AUReverb2::decayTimeAt0Hz(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_DecayTimeAt0Hz, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2::decayTimeAtNyquist()
{
    return _getParameter(kReverb2Param_DecayTimeAtNyquist);
}

void AUReverb2::decayTimeAtNyquist(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_DecayTimeAtNyquist, value);
}

//---------------------------------------------------------------------

AudioUnitParameterValue AUReverb2::AUReverb2::randomizeReflections()
{
    return _getParameter(kReverb2Param_RandomizeReflections);
}

void AUReverb2::randomizeReflections(AudioUnitParameterValue value)
{
    _setParameter(kReverb2Param_RandomizeReflections, value);
}

//---------------------------------------------------------------------






