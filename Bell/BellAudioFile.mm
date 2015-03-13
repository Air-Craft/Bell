//
//  BellAudioFile.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 18/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <tgmath.h>
#import "BellAudioFile.h"
#import "BellDefs.h"
#import "BellExceptions.h"
#import "BellUtils.h"


@implementation BellAudioFile
{
    BellSize _readPosInFrames;    ///< Track read position to prevent unnecessary Seeks on Read
    NSMutableData *_preloadBufferL;
    NSMutableData *_preloadBufferR;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
/////////////////////////////////////////////////////////////////////////

+ (instancetype)openAudioFileWithURL:(NSURL *)fileURL
{
    id me = [self new];
    [me openAudioFileWithURL:fileURL];
    return me;
}

//---------------------------------------------------------------------

+ (instancetype)createNewAudioFileWithURL:(NSURL *)fileURL fileFormat:(BellAudioFileFormatDescription)fileFormat
{
    id me = [self new];
    [me createNewAudioFileWithURL:fileURL fileFormat:fileFormat];
    return me;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////

- (void)openAudioFileWithURL:(NSURL *)fileURL
{
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);

    // Only allow opening once
    if (fileRef) {
        [NSException raise:NSGenericException format:@"A file had already been opened/created"];
    }
    
    _currentReadPosition = 0;   // Init to start of file
    _eof = NO;
    
    _fileURL = [fileURL copy];
    UInt32 s;   // for property variable sizes
    
    // Open the file
    _(ExtAudioFileOpenURL((__bridge CFURLRef)_fileURL, &fileRef),
      @"Failed to open file %@", _fileURL.lastPathComponent);
    
    
    // Get the format description
    s = sizeof(AudioStreamBasicDescription);
    _(ExtAudioFileGetProperty(fileRef,
                              kExtAudioFileProperty_FileDataFormat,
                              &s,
                              &_fileStreamFormat),
      @"Error reading ASBD from file %@", _fileURL.lastPathComponent);

    // Set the default output format
    self.clientStreamFormat = kBellCanonicalStreamFormat;     // Sets the property on the ExtAudioFile as well
}

//---------------------------------------------------------------------

- (void)createNewAudioFileWithURL:(NSURL *)fileURL fileFormat:(BellAudioFileFormatDescription)fileFormat
{
    NSParameterAssert(fileFormat.fileTypeId);
    // Only allow opening once
    if (fileRef) {
        [NSException raise:NSGenericException format:@"A file had already been opened/created"];
    }
    
    // @TEMP Fix me when swift is better
    BellAudioFileFormatDescription ff = kBellFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian;
//    BellAudioFileFormatDescription ff = fileFormat;
    
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);
    
    ExtAudioFileRef newFileRef;
    
    _(ExtAudioFileCreateWithURL((__bridge CFURLRef)fileURL,
                                ff.fileTypeId,
                                &ff.streamFormat,
                                NULL,
                                kAudioFileFlags_EraseFile,
                                &newFileRef),
      @"Failed to open audio file %@ for writing.", fileURL);
    
    // Set the ivars
    _fileStreamFormat = ff.streamFormat;
    _fileURL = fileURL;
    fileRef = newFileRef;
    
    // Set the client data format for how we'll feed it.  Defaults to Canonical
    // (Needs ->fileRef set)
    self.clientStreamFormat = kBellCanonicalStreamFormat;
    
    // Explicitly set the codec (hardware/software) to prevent various issues
    // See http://michaelchinen.com/2012/04/30/ios-encoding-to-aac-with-the-extended-audio-file-services-gotchas/
    _(ExtAudioFileSetProperty(newFileRef,
                              kExtAudioFileProperty_CodecManufacturer,
                              sizeof(ff.codecManufacturer),
                              &ff.codecManufacturer),
      @"Error setting the codec manufacturer (hardware/software) for audio file %@", fileURL.absoluteString);
}

//---------------------------------------------------------------------

- (void)close
{
//    NSAssert(fileRef, @"Closing when file not opened!");
    // @TODO error handling?
    ExtAudioFileDispose(fileRef);
    fileRef = NULL;
}

//---------------------------------------------------------------------

- (void)reopenForReading
{
    [self close];
    [self openAudioFileWithURL:_fileURL];
}

//---------------------------------------------------------------------

- (void)dealloc
{
    // Clean up if needed
    if (fileRef) {
        [self close];
    }
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
/////////////////////////////////////////////////////////////////////////

- (BellSize)lengthInFrames
{
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);
 
    BellSize lengthInFrames;
    UInt32 s = sizeof(lengthInFrames);
    _(ExtAudioFileGetProperty(fileRef,
                              kExtAudioFileProperty_FileLengthFrames,
                              &s,
                              &lengthInFrames),
      @"Error reading frame length from file %@", _fileURL.lastPathComponent);
    
    return lengthInFrames;
}

//---------------------------------------------------------------------

- (NSTimeInterval)lengthInSeconds
{
    return self.lengthInFrames / _fileStreamFormat.mSampleRate;
}

//---------------------------------------------------------------------

- (void)setFileStreamFormat:(AudioStreamBasicDescription)fileStreamFormat
{
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);

    UInt32 s = sizeof(AudioStreamBasicDescription);
    _(ExtAudioFileSetProperty(fileRef,
                              kExtAudioFileProperty_FileDataFormat,
                              s,
                              &fileStreamFormat),
      @"Couldn't set file stream format on file %@", _fileURL.lastPathComponent);
    
    _fileStreamFormat = fileStreamFormat;
}

//---------------------------------------------------------------------

- (void)setClientStreamFormat:(AudioStreamBasicDescription)clientStreamFormat
{
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);
    
    UInt32 s = sizeof(AudioStreamBasicDescription);
    _(ExtAudioFileSetProperty(fileRef,
                              kExtAudioFileProperty_ClientDataFormat,
                              s,
                              &clientStreamFormat),
    @"Couldn't set client stream format on file %@", _fileURL.lastPathComponent);
    
    _clientStreamFormat = clientStreamFormat;
}



/////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods
/////////////////////////////////////////////////////////////////////////

- (BellSize)preloadFrames:(BellSize)framesToPreload
{
    // Client format as it's converted to this when reading
    BellSize byteSize = framesToPreload * _clientStreamFormat.mBytesPerFrame;
    _preloadBufferL = [NSMutableData dataWithLength:byteSize];
    _preloadBufferR = [NSMutableData dataWithLength:byteSize];
    
    BellSize framesPreloaded = [self readFrames:framesToPreload
                                      fromFrame:0
                                    intoBufferL:_preloadBufferL.mutableBytes
                                        bufferR:_preloadBufferR.mutableBytes];
    _preloadedFrames = framesPreloaded;
    return _preloadedFrames;
}

//---------------------------------------------------------------------

- (void)seekToFrame:(BellSize)theFrame
{
    auto _ = bell::ErrorChecker([BellAudioModuleException class]);
    
    if (theFrame >= self.lengthInFrames) {
        [NSException raise:NSRangeException format:@"Frame %lu out of bounds for file %@ of length %lu frames)", (unsigned long)theFrame, _fileURL.lastPathComponent, (unsigned long)self.lengthInFrames];
    }
    _currentReadPosition = theFrame;
    _(ExtAudioFileSeek(fileRef, theFrame),
      @"Error seeking to frame %i in file %@", theFrame, _fileURL.lastPathComponent);
    
    _eof = NO;
}

//---------------------------------------------------------------------

- (void)reset
{
    _currentReadPosition = 0;
    _eof = NO;
}

//---------------------------------------------------------------------

- (void)readFromFrame:(BellSize)startFrame toFrame:(BellSize)endFrame withChunkSize:(BellSize)framesPerChunk usingBlock:(void (^)(AudioBufferList *, BellSize, BellSize))readCallback
{
    // Prep a reusable ABL...
    AudioBufferList *abl = Bell_CreateAudioBufferList((BellSize)_clientStreamFormat.mChannelsPerFrame, (BellSize)(_clientStreamFormat.mBytesPerFrame * framesPerChunk));
    
    // Silently cap endFrame to the last one in the file
    if (endFrame >= self.lengthInFrames) {
        endFrame = self.lengthInFrames - 1;
    }
    
    // Read and then call out callback block
    BellSize pos = startFrame;
    BellSize framesActuallyRead;
    do {
        framesActuallyRead =
        [self readFrames:framesPerChunk fromFrame:pos intoAudioBufferList:abl];
        
        // Call the block
        readCallback(abl, framesActuallyRead, pos);
        
        pos += framesActuallyRead;
    } while (pos < endFrame && framesActuallyRead == framesPerChunk && !self.eof);
    // Bail if we reach the end or the file or our frame length
    
    // Cleanup
    Bell_ReleaseAudioBufferList(abl);
}

//---------------------------------------------------------------------

- (BellSize)readFrames:(BellSize)theFrameCount intoBufferL:(void *)aBufferL bufferR:(void *)aBufferR
{
    return [self readFrames:theFrameCount fromFrame:_currentReadPosition intoBufferL:aBufferL bufferR:aBufferR];
}

//---------------------------------------------------------------------

- (BellSize)readFrames:(BellSize)theFrameCount
             fromFrame:(BellSize)theStartFrame
           intoBufferL:(void *)aBufferL
               bufferR:(void *)aBufferR
{
    // Get the data size required
    BellSize dataSizeBytes = _clientStreamFormat.mBytesPerFrame * theFrameCount;
    
    // Malloc the ABL
    void *buffers[2] = {aBufferL, aBufferR};
    AudioBufferList *abl = Bell_CreateAudioBufferListUsingExistingBuffers(_clientStreamFormat.mChannelsPerFrame, buffers, dataSizeBytes);
    
    // Setup and assign the underlying buffer to our pointer argument
    abl->mNumberBuffers = _clientStreamFormat.mChannelsPerFrame;
    abl->mBuffers[0].mNumberChannels = 1;               // always 1 for non-interleaved
    abl->mBuffers[0].mDataByteSize = (UInt32)dataSizeBytes;
    abl->mBuffers[0].mData = aBufferL;
    
    // Create the other buffer only if stereo
    // ? SHOULD THIS BE fileStreamFormat?
    if (_clientStreamFormat.mChannelsPerFrame > 1) {
        abl->mBuffers[1].mNumberChannels = 1;
        abl->mBuffers[1].mDataByteSize = (UInt32)dataSizeBytes;
        abl->mBuffers[1].mData = aBufferR;
    }
    
    BellSize framesRead = [self readFrames:theFrameCount fromFrame:theStartFrame intoAudioBufferList:abl];
    
    // If mono then copy to aBufferR
    if (_clientStreamFormat.mChannelsPerFrame == 1) {
        memcpy(aBufferR, aBufferL, dataSizeBytes);
    }
    
    Bell_ReleaseAudioBufferListPreservingBuffers(abl);
    
    return framesRead;
}

//---------------------------------------------------------------------

- (BellSize)readFrames:(BellSize)theFrameCount fromFrame:(BellSize)theStartFrame intoAudioBufferList:(AudioBufferList *)theAudioBufferList
{
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);

    // Attempt to pull from the preload buffer but only if it has them all (for now)
    // @TODO Make the read smart about pulling segments of the priming buffer
    if (_preloadedFrames > 0 // for speed
        && theStartFrame + theFrameCount <= _preloadedFrames)
    {
        info("Reading %i frames from Preload Buffer", (int)theFrameCount);
        BellSize byteSize = theFrameCount * _clientStreamFormat.mBytesPerFrame;
        BellSize bytesFrom = theStartFrame * _clientStreamFormat.mBytesPerFrame;
        const void *fromL = (char *)_preloadBufferL.mutableBytes + bytesFrom;
        const void *fromR = (char *)_preloadBufferR.mutableBytes + bytesFrom;
        memcpy(theAudioBufferList->mBuffers[0].mData, fromL, byteSize);
        memcpy(theAudioBufferList->mBuffers[1].mData, fromR, byteSize);
        return theFrameCount;
    }
    
    // Don't check bounds.  Will return the number of frames read if less than requested.  This is how you determine EOF
    
    BellSize framesToReadAndRead = theFrameCount;
    
    // Seek if required
    if (theStartFrame != _currentReadPosition) {
        _(ExtAudioFileSeek(fileRef, theStartFrame),
          @"Error seeking to frame %i in file %@", theStartFrame, _fileURL.lastPathComponent);
    }
    
    // Workaround for antiquated typing in CoreAudio
    UInt32 frames2RR = (UInt32)framesToReadAndRead;
    _(ExtAudioFileRead(fileRef, &frames2RR, theAudioBufferList),
      @"Error reading %i - %i frames from file %@", theStartFrame, theStartFrame+theFrameCount, _fileURL.lastPathComponent);
    framesToReadAndRead = frames2RR;
    
    // update read head
    _currentReadPosition = theStartFrame + framesToReadAndRead;
    
    // EOF?
    if (_currentReadPosition >= self.lengthInFrames) {
        _eof = YES;
        //MMLogRealTime(@"EOF reached for file %@", _fileURL.lastPathComponent);
    } else {
        _eof = NO;  // Reset eof if we're back on track
    }
    
    return framesToReadAndRead;
}

//---------------------------------------------------------------------

- (void)readWaveformPreviewDataIntoLeftChannelDataBuffer:(out NSData *__autoreleasing *)leftDataPtr rightChannelDataBuffer:(out NSData *__autoreleasing *)rightDataPtr withDownSampleFactor:(float)downsampleFactor
{
    NSParameterAssert(downsampleFactor >= 1.0); // No upsampling for now
    NSParameterAssert(leftDataPtr); // we need at least one
    
    // Process as mono (combine channels) if rightDataPtr not provided
    BOOL asMono = (rightDataPtr == NULL || self.fileStreamFormat.mChannelsPerFrame == 1);
    
    // Allocate the data buffer(s) based on the desired size
    BellSize inputFrames = (BellSize)self.lengthInFrames;
    size_t inputBytes = _clientStreamFormat.mBytesPerFrame * inputFrames;
    void *left = malloc(inputBytes);
    void *right = malloc(inputBytes);    // do this even if mono as read needs it
    
    // Read from the file and grab the actual read size
    [self seekToFrame:0];
    BellSize framesRead = [self readFrames:inputFrames intoBufferL:left bufferR:right];
    
    // Calculate the downsampled sizes
    size_t outputFrames = round(framesRead / downsampleFactor);
    size_t outputBytes = outputFrames * _clientStreamFormat.mBytesPerFrame;
    
    
    // Do the downsampling using Accelerate
    // We'll do a "gather" operation so make a ramp incremented by the downsample fact
    float v0 = 1;  // one-base indices for vDSP gather ops
    float *indexRampBuff = (float *)malloc(framesRead);
    vDSP_vramp(&v0, &downsampleFactor, indexRampBuff, 1, outputFrames);
    
    // If mono then average the two buffers but only if there are two
    if (asMono && self.fileStreamFormat.mChannelsPerFrame != 1) {
        const float div2 = 0.5;
        vDSP_vasm((float *)left, 1, (float *)right, 1, &div2, (float *)left, 1, framesRead);
    }
    
    // Now downsample...
    vDSP_vindex((float *)left, indexRampBuff, 1, (float *)left, 1, outputFrames);
    if (!asMono) {
        vDSP_vindex((float *)right, indexRampBuff, 1, (float *)right, 1, outputFrames);
    }
    
    // Construct the NSData objects
    *leftDataPtr = [NSData dataWithBytesNoCopy:left length:outputBytes freeWhenDone:YES];
    if (!asMono) {
        *rightDataPtr = [NSData dataWithBytesNoCopy:right length:outputBytes freeWhenDone:YES];
    } else {
        free(right);
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - Write Methods
/////////////////////////////////////////////////////////////////////////

- (void)writeFrames:(BellSize)theFrameCount fromAudioBufferList:(AudioBufferList *)abl
{
    auto _ = bell::ErrorChecker([BellAudioFileIOException class]);

    _(ExtAudioFileWrite(fileRef, (UInt32)theFrameCount, abl),
      @"Failed to write %i frames to file %@", (int)theFrameCount, _fileURL);
}


@end

