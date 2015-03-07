//
//  AUFilePlayerRenderer.h
//  AUMLansingAudioBrains
//
//  Created by Hari Karam Singh on 15/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#ifndef __Marshmallows__AUFilePlayerRenderer__
#define __Marshmallows__AUFilePlayerRenderer__

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AUAudioModuleBase.h"
#import "AUMAudioFile.h"

namespace AUM {
    
    class AUFilePlayerModule : public AUAudioModuleBase
    {
    public:
        AUFilePlayerModule() : AUAudioModuleBase(), _loop(false) {}
        
        /** @throws AUMAudioModuleException if output format does not match our canonical */
        void loadAudioFile(AUMAudioFile *audioFile);

        /** @throws AUMAudioModuleException on error */
        void play();

        /**
         Only works for now on files with a fixed sample rate. Others will through an exception
         @TODO Make this work for non-fixed sample rate types
         @throws AUMAudioModuleException on error
         */
        void playFromTime(NSTimeInterval startTime);
        
        /** @throws AUMAudioModuleException on error */
        void playFromFrame(UInt32 startFrame);
        
        /** @throws AUMAudioModuleException */
        void stop();
        
        /** In seconds relative to the beginning of the file (as opposed to the AU convention of relative to the start of play which differs if not the beginning)
            @throws AUMAudioModuleException 
         */
        NSTimeInterval playheadTime();
        
        /** In frame units plus fraction?
            @throws AUMAudioModuleException
         */
        Float64 playheadFrame();
        
        
        void loop(bool l) { _loop = l; }
        bool loop() { return _loop; }
    
    protected:
        AUMAudioFile *_audioFile;
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



#endif /* defined(__Marshmallows__AUFilePlayerRenderer__) */
