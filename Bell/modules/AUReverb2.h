//
//  ReverbAUModule.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 31/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUModuleBase.h"
#import "BellAudioFile.h"

namespace bell {
    namespace modules {
        class AUReverb2 : public AUModuleBase
        {
        public:
            AUReverb2() : AUModuleBase() {}
            
            /** For details see: file:///Users/Club15CC/Library/Developer/Shared/Documentation/DocSets/com.apple.adc.documentation.AppleiOS7.1.iOSLibrary.docset/Contents/Resources/Documents/documentation/AudioUnit/Reference/AudioUnitParametersReference/Reference/reference.html#//apple_ref/c/econst/kReverb2Param_Gain */
            
            AudioUnitParameterValue dryWetMix();        // 0..100 (percent)
            void dryWetMix(AudioUnitParameterValue value);
            AudioUnitParameterValue gain();             // -20dB - +2-dB
            void gain(AudioUnitParameterValue value);
            AudioUnitParameterValue minDelayTime();     // 0.0001 -> 1.0s
            void minDelayTime(AudioUnitParameterValue value);
            AudioUnitParameterValue maxDelayTime();
            void maxDelayTime(AudioUnitParameterValue value);
            AudioUnitParameterValue decayTimeAt0Hz();   // 0.1 -> 20a
            void decayTimeAt0Hz(AudioUnitParameterValue value);
            AudioUnitParameterValue decayTimeAtNyquist();   // 0.1 -> 20a
            void decayTimeAtNyquist(AudioUnitParameterValue value);
            AudioUnitParameterValue randomizeReflections();  // 1 -> 1000
            void randomizeReflections(AudioUnitParameterValue value);
            
            
        private:
            void _willInitializeAU();
            const AudioComponentDescription _auComponentDescription();
        };
        
    }
}