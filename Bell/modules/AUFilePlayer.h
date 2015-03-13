//
//  AUFilePlayerRenderer.h
//  BellLansingAudioBrains
//
//  Created by Hari Karam Singh on 15/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#ifndef __Marshmallows__AUFilePlayerRenderer__
#define __Marshmallows__AUFilePlayerRenderer__

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUModuleBase.h"
#import "BellAudioFile.h"

namespace bell {
    namespace modules {
        class AUFilePlayer : public AUModuleBase
        {
        public:
            AUFilePlayer() : AUModuleBase(), _loop(false) {}
            
            /** @throws BellAudioModuleException if output format does not match our canonical */
            void loadAudioFile(BellAudioFile *audioFile);
            
            /** @throws BellAudioModuleException on error */
            void play();
            
            /**
             Only works for now on files with a fixed sample rate. Others will through an exception
             @TODO Make this work for non-fixed sample rate types
             @throws BellAudioModuleException on error
             */
            void playFromTime(NSTimeInterval startTime);
            
            /** @throws BellAudioModuleException on error */
            void playFromFrame(UInt32 startFrame);
            
            /** @throws BellAudioModuleException */
            void stop();
            
            /** In seconds relative to the beginning of the file (as opposed to the AU convention of relative to the start of play which differs if not the beginning)
             @throws BellAudioModuleException
             */
            NSTimeInterval playheadTime();
            
            /** In frame units plus fraction?
             @throws BellAudioModuleException
             */
            Float64 playheadFrame();
            
            
            void loop(bool l) { _loop = l; }
            bool loop() { return _loop; }
            
        protected:
            BellAudioFile *_audioFile;
            bool _loop;
            
            /** We need to track this to report "playhead" times relative to file start */
            UInt32 _startFrame;
            
            /** @override */
            void _willInitializeAU();
            
        private:
            /// Define the component description.  Private as it wouldn't make much sense to change this
            const AudioComponentDescription _auComponentDescription(void);
            
            
        };
    }
}



#endif /* defined(__Marshmallows__AUFilePlayerRenderer__) */
