//
//  AUMUtils.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 18/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


#ifdef __cplusplus
extern "C" {
#endif
   
    
/** NSLog a list of supported mFormatFlahs and other info for the given container and audio data format
 
 Special thx to Learning Core Audio: http://www.amazon.co.uk/Learning-Core-Audio-Hands-Programming/dp/0321636848
 */
void AUM_printAvailableStreamFormatsForId(AudioFileTypeID fileTypeID, UInt32 mFormatID);

void AUM_printWritableTypes();
    
void AUM_tmp();
    
AudioBufferList *AUM_CreateAudioBufferList(UInt32 numChannels, UInt32 bufferBytesSize);

/** Be sure to release it when done */
AudioBufferList *AUM_CreateAudioBufferListUsingExistingBuffers(UInt32 numChannels, void *buffers[], UInt32 bufferBytesSize);

/** Frees memory from the ABL as well as the underlying buffers */
void AUM_ReleaseAudioBufferList(AudioBufferList *abl);

/** Just release the ABL, not the underlying buffers */
void AUM_ReleaseAudioBufferListPreservingBuffers(AudioBufferList *abl);

    
    
#ifdef __cplusplus
}
#endif