//
//  BellUtils.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 18/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BellDefs.h"

#ifdef __cplusplus
extern "C" {
#endif
   
    
/** NSLog a list of supported mFormatFlahs and other info for the given container and audio data format
 
 Special thx to Learning Core Audio: http://www.amazon.co.uk/Learning-Core-Audio-Hands-Programming/dp/0321636848
 */
void Bell_printAvailableStreamFormatsForId(AudioFileTypeID fileTypeID, UInt32 mFormatID);

void Bell_printWritableTypes();
    
void Bell_tmp();
    
AudioBufferList *Bell_CreateAudioBufferList(BellSize numChannels, BellSize bufferBytesSize);

/** Be sure to release it when done */
AudioBufferList *Bell_CreateAudioBufferListUsingExistingBuffers(BellSize numChannels, void *buffers[], BellSize bufferBytesSize);

/** Frees memory from the ABL as well as the underlying buffers */
void Bell_ReleaseAudioBufferList(AudioBufferList *abl);

/** Just release the ABL, not the underlying buffers */
void Bell_ReleaseAudioBufferListPreservingBuffers(AudioBufferList *abl);

    
    
#ifdef __cplusplus
}
#endif