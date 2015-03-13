//
//  BellAudioFile.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 18/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BellDefs.h"

/**
 \brief     Wrapper around Ext Audio File Services to allow reading of arbitrary files into arbitrary output format.  clientStreamFormat defaults to Linear PCM/44.1/16bit/stereo/floating point/native endian/interleaved.  Set after init to change.
 
 \par   Usage styles
 This will work as a sequential linear reader via [readFrames:intoBufferL:bufferR] or via the random access methods.  Both update the readHeadPosInFrames property. eof is set when th
 */
@interface BellAudioFile : NSObject
{
@public
    /** Generally discourage but needed by some internals and needs to be free from objc black magic */
    ExtAudioFileRef fileRef;
    
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

@property (strong, nonatomic, readonly) NSURL *fileURL;

/** Length of the audio */
@property (nonatomic, readonly) BellSize lengthInFrames;

@property (nonatomic, readonly) NSTimeInterval lengthInSeconds;

/** Count of the number of frames preloaded */
@property (nonatomic, readonly) BellSize preloadedFrames;

/** Readonly property representing the stream format of the file's data or the encoding format for record
 @throws BellAudioFileIOException on error when setting
 */
@property (nonatomic, readonly) AudioStreamBasicDescription fileStreamFormat;

/** Sets the format for the data going into the record or out of the read
 @throws BellAudioFileIOException on error when setting */
@property (nonatomic) AudioStreamBasicDescription clientStreamFormat;

@property (nonatomic, readonly) BOOL eof;

@property (nonatomic, readonly) BellSize currentReadPosition;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

/** See initForURL: */
+ (instancetype)openAudioFileWithURL:(NSURL *)fileURL;
+ (instancetype)createNewAudioFileWithURL:(NSURL *)fileURL fileFormat:(BellAudioFileFormatDescription)fileFormat;


/////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
/////////////////////////////////////////////////////////////////////////

/**
 Load the Audio File Service reference and get the property data for the specified URL
 
 \throws BellAudioFileIOException
 \return Nil if there was a problem along with [SEOpenALWrapper messages...
 */
- (void)openAudioFileWithURL:(NSURL *)fileURL;
- (void)createNewAudioFileWithURL:(NSURL *)fileURL fileFormat:(BellAudioFileFormatDescription)fileFormat;

- (void)close;

/** Call after creating and recording */
- (void)reopenForReading;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Read Methods
/////////////////////////////////////////////////////////////////////////

/** 
 Allocates a buffer and pre-reads the given froms from the start. Subsequent reads which cover this range PROVIDED THAT the entire chunk can come from the buffer (otherwise the preload buffer is skipped entirely)
 
 @TODO Make the read smart about pulling segments of the priming buffer
 
 @return Actual num frames preloaded
 */
- (BellSize)preloadFrames:(BellSize)framesToPreload;

/** Set the next read position for readFrame:intoBufferL:bufferB.  Essentially a setter for readHeadPosInFrames */
- (void)seekToFrame:(BellSize)theFrame;

/** Sets readHead back to 0 and clears eof */
- (void)reset;


- (void)readFromFrame:(BellSize)startFrame
              toFrame:(BellSize)endFrame
        withChunkSize:(BellSize)framesPerChunk
           usingBlock:(void (^)(AudioBufferList *audioData,
                                BellSize framesRead,
                                BellSize frameOffset
                                ))readCallback;

/**
 \brief Read specified frames from the current readHeadPosInFrames, updating accordingly.  Use for linear streaming reads (as opposed to random access)
 */
- (BellSize)readFrames:(BellSize)theFrameCount intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR;


/**
 \brief Convenience method for reading stereo data directly in void * buffers.  If mono then the channel will be copied to both
 */
- (BellSize)readFrames:(BellSize)theFrameCount fromFrame:(BellSize)theStartFrame intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR;

/**
 The designated read method.  All others call this. Reads frames from a specified starting position and return the number actually read.
 \property theBufferList    MUST BE properly malloc'ed prior!
 \throws BellAudioFileIOException
 \return the Number of frames actually read (0 for error, less than requested for EOF)
 */
- (BellSize)readFrames:(BellSize)theFrameCount fromFrame:(BellSize)theStartFrame intoAudioBufferList:(AudioBufferList *)theAudioBufferList;

/**  */
- (void)readWaveformPreviewDataIntoLeftChannelDataBuffer:(out NSData **)leftDataPtr rightChannelDataBuffer:(out NSData **)rightDataPtr withDownSampleFactor:(float)downsampleFactor;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Write Methods
/////////////////////////////////////////////////////////////////////////

/** Includes the number of frames to be written inside. */
- (void)writeFrames:(BellSize)theFrameCount fromAudioBufferList:(AudioBufferList *)abl;



@end
