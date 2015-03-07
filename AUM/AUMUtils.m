//
//  AUMUtils.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 18/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import "AUMUtils.h"
#import "AUMDefs.h"


void AUM_tmp()
{
//    AudioFormatGetPropertyInfo(
}

//---------------------------------------------------------------------


void AUM_printWritableTypes()
{
    OSStatus err = noErr;
    UInt32 infoSize = 0;
    err = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_WritableTypes,
                                          0,
                                          NULL,
                                          &infoSize);
    if (err != noErr) {
        UInt32 format4cc = CFSwapInt32HostToBig(err);
        NSLog(@"Error: (%4.4s)",
              (char*)&format4cc
              );
        
        return;
    }
    
    UInt32 typeIDs[infoSize];
    err = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_WritableTypes,
                                      0,
                                      NULL,
                                      &infoSize,
                                      typeIDs);
    if (err != noErr) {
        UInt32 format4cc = CFSwapInt32HostToBig(err);
        NSLog(@"Error: (%4.4s)",
              (char*)&format4cc
              );
        
        return;
    }
    
    
    int count = infoSize / sizeof (UInt32);
    for (int i=0; i<count; i++) {

        // Do the same process to get the string names
        UInt32 outSize = 0;
        UInt32 typeID = typeIDs[i];
//        err = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_FileTypeName,
//                                         sizeof(typeID),
//                                         &typeID,
//                                         &outSize);
        CFStringRef str;
        outSize = sizeof(CFStringRef);
        err = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_FileTypeName,
                                     sizeof(typeID),
                                     &typeID,
                                     &outSize,
                                     &str);
        
        NSLog(@"ID: %li\t\tName: %@",
              (unsigned long)typeID,
              str);
        CFBridgingRelease(str);
    }
    
    
}

//---------------------------------------------------------------------


void AUM_printAvailableStreamFormatsForId(AudioFileTypeID fileTypeID, UInt32 mFormatID)
{
    AudioFileTypeAndFormatID fileTypeAndFormat;
    fileTypeAndFormat.mFileType = fileTypeID;
    fileTypeAndFormat.mFormatID = mFormatID;
    UInt32 fileTypeIDChar = CFSwapInt32HostToBig(fileTypeID);
    UInt32 mFormatChar = CFSwapInt32HostToBig(mFormatID);
    
    OSStatus audioErr = noErr;
    UInt32 infoSize = 0;
    audioErr = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
                                          sizeof (fileTypeAndFormat),
                                          &fileTypeAndFormat,
                                          &infoSize);
    if (audioErr != noErr) {
        UInt32 format4cc = CFSwapInt32HostToBig(audioErr);
        NSLog(@"-: fileTypeID: %4.4s, mFormatId: %4.4s, not supported (%4.4s)",
              //i,
              (char*)&fileTypeIDChar,
              (char*)&mFormatChar,
              (char*)&format4cc
              );
        
        return;
    }
    
    AudioStreamBasicDescription *asbds = malloc (infoSize);
    audioErr = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
                                      sizeof (fileTypeAndFormat),
                                      &fileTypeAndFormat,
                                      &infoSize,
                                      asbds);
    if (audioErr != noErr) {
        UInt32 format4cc = CFSwapInt32HostToBig(audioErr);
        NSLog(@"-: fileTypeID: %4.4s, mFormatId: %4.4s, not supported (%4.4s)",
              //i,
              (char*)&fileTypeIDChar,
              (char*)&mFormatChar,
              (char*)&format4cc
              );
        
        return;
    }
    
    
    int asbdCount = infoSize / sizeof (AudioStreamBasicDescription);
    for (int i=0; i<asbdCount; i++) {
        UInt32 format4cc = CFSwapInt32HostToBig(asbds[i].mFormatID);
        
        NSLog(@"%d: fileTypeID: %4.4s, mFormatId: %4.4s, mFormatFlags: %ld, mBitsPerChannel: %ld",
              i,
              (char*)&fileTypeIDChar,
              (char*)&format4cc,
              asbds[i].mFormatFlags,
              asbds[i].mBitsPerChannel);
    }
    
    free (asbds);
}


//---------------------------------------------------------------------

AudioBufferList *AUM_CreateAudioBufferList(UInt32 numChannels, UInt32 bufferBytesSize)
{
    // Allocate the underlying buffers...
    void **buffers = malloc(sizeof(void *) * numChannels);
    for (int i=0; i<numChannels; i++) {
        buffers[i] = malloc(bufferBytesSize);
    }
    
    return AUM_CreateAudioBufferListUsingExistingBuffers(numChannels, buffers, bufferBytesSize);
}

//---------------------------------------------------------------------

/** Creates a non-interleaved ABL with the given number of channels using pre-allocated buffers */
AudioBufferList *AUM_CreateAudioBufferListUsingExistingBuffers(UInt32 numChannels, void *buffers[], UInt32 bufferBytesSize)
{
    AudioBufferList *abl;
    UInt32 ablSize = offsetof(AudioBufferList, mBuffers[0]) + sizeof(AudioBuffer) * numChannels;
    abl = malloc(ablSize);
    
    abl->mNumberBuffers = numChannels;
    
    for (int i=0; i<numChannels; i++) {
        abl->mBuffers[i].mDataByteSize = bufferBytesSize;
        abl->mBuffers[i].mNumberChannels = 1;   // non-interleaved is always 1
        abl->mBuffers[i].mData = buffers[i];
    }
    
    return abl;
}

//---------------------------------------------------------------------

void AUM_ReleaseAudioBufferList(AudioBufferList *abl)
{
    // Free the individual data bufers
    for (int i=0; i < abl->mNumberBuffers; i++) {
        free(abl->mBuffers[i].mData);
    }
    
    // Free the struct (we alloc'ed the whole thing at once)
    free(abl);
}

//---------------------------------------------------------------------

void AUM_ReleaseAudioBufferListPreservingBuffers(AudioBufferList *abl)
{
    free(abl);
}





