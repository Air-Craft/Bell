//
//  BellRingBuffer.h
//  SW-Guitar
//
//  Created by Hari Karam Singh on 08/03/2015.
//
//
#ifndef bell_RingBuffer
#define bell_RingBuffer 1


#include <libkern/OSAtomic.h>
#include "BellDefs.h"


namespace bell {
    
    /**
     Object-oriented, highly optimised RingBuffer for audio.  Currently pure C++ though utilises Darwin specifics (see below). Also, copy and assignment constructors are disabled so use only with pointers for now (avoiding dealing with ownership issues when we're likely not to encounter them anyway)
     
     //  Inspired by TPCircularBuffer.h by Michael Tyson
     //
     //  This implementation makes use of a virtual memory mapping technique that inserts a virtual copy
     //  of the buffer memory directly after the buffer's end, negating the need for any buffer wrap-around
     //  logic. Clients can simply use the returned memory address as if it were contiguous space.
     //
     //  The implementation is thread-safe in the case of a single producer and single consumer.
     //
     //  Virtual memory technique originally proposed by Philip Howard (http://vrb.slashusr.org/), and
     //  adapted to Darwin by Kurt Revis (http://www.snoize.com,
     //  http://www.snoize.com/Code/PlayBufferedSoundFile.tar.gz)
     //
     */
    class RingBuffer
    {
    private:
        /////////////////////////////////////////////////////////////////////////
        #pragma mark - IVars
        /////////////////////////////////////////////////////////////////////////
        BellSize _lengthInBytes;
        BellSize _bytesPerFrame;
        
        BellSample *_bufferL;
        BellSample *_bufferR;
        BellSize _tailPos;      // head and tail bytes positions
        BellSize _headPos;
        volatile int64_t _fillCountInBytes;    // how many bytes are written. Should be head-tail but I've taken this from TPCircularBuffer just in case. My research indicates that the volatile keyword doens't really do much. If nothing else the variable minimises transactions required to report the value and thus is better wrt to atomicity (whereas the maths in a smart getter would involve 2 variables a subtraction op)
        
        
    public:
        
        /////////////////////////////////////////////////////////////////////////
        #pragma mark - Life Cycle
        /////////////////////////////////////////////////////////////////////////

        RingBuffer() { throw 1; };
        RingBuffer(BellSize lengthInFrames);
        ~RingBuffer();
        
    // Disables the other 2 in the rule of three as we'll only be using this in pointer form
    private:
        RingBuffer(const RingBuffer&);
        RingBuffer& operator=(const RingBuffer&);
        
        /////////////////////////////////////////////////////////////////////////
        #pragma mark - Public Methods
        /////////////////////////////////////////////////////////////////////////

    public:
        inline BellSize availableReadFrames() const;
        inline BellSize availableWriteFrames() const;
        
        /** 
         Grab a pointers to the internal buffers

         @param R  Pass NULL to just use the L channel
         */
        inline void grabReadBuffer(BellSample **L, BellSample **R) const;
        inline void grabWriteBuffer(BellSample **L, BellSample **R) const;
        
        /** Mark the given number of frames as having been read/written. Use after ops on buffers returned by writeBuffer/readBuffer */
        inline void markFramesRead(BellSize numFrames);
        inline void markFramesWritten(BellSize numFrames);

        /** 
         Convenience methods which copy the data to/from the given buffers and then update the read/write position
         @param R   Pass NULL to just use L channel
         @return frames actually read or written 
         */
        inline BellSize readFromBuffer(BellSample *L, BellSample *R, BellSize const numFrames);
        inline BellSize writeIntoBuffer(BellSample const *L, BellSample const *R, BellSize const numFrames);
        
        /** Reset to empty. Doesn't clear the actual memory values */
        void clear();
        
        
    private:
        
        /////////////////////////////////////////////////////////////////////////
        #pragma mark - Additional Privates
        /////////////////////////////////////////////////////////////////////////
        
        /** Sets up the VM magic for the internal buffers */
        void *_allocateBuffer(BellSize sizeInBytes);
    };
}


/////////////////////////////////////////////////////////////////////////
#pragma mark - Inlines
/////////////////////////////////////////////////////////////////////////
using namespace bell;

BellSize RingBuffer::availableReadFrames() const
{
    return _fillCountInBytes / _bytesPerFrame;
}

//---------------------------------------------------------------------

BellSize RingBuffer::availableWriteFrames() const
{
    return (_lengthInBytes - _fillCountInBytes) / _bytesPerFrame;
}

//---------------------------------------------------------------------

void RingBuffer::grabReadBuffer(BellSample **L, BellSample **R) const
{
    *L = (BellSample *)((char *)_bufferL + _tailPos);
    *R = (BellSample *)((char *)_bufferR + _tailPos);
}

//---------------------------------------------------------------------

void RingBuffer::grabWriteBuffer(BellSample **L, BellSample **R) const
{
    *L = (BellSample *)((char *)_bufferL + _headPos);
    
    if (R != NULL)
        *R = (BellSample *)((char *)_bufferR + _headPos);
}

//---------------------------------------------------------------------

void RingBuffer::markFramesRead(BellSize numFrames)
{
    assert(numFrames <= availableReadFrames());
    
    BellSize bytes = _bytesPerFrame * numFrames;
    
    _tailPos = (_tailPos + bytes) % _lengthInBytes;
    OSAtomicAdd64Barrier(-(int64_t)bytes, &_fillCountInBytes);
}

//---------------------------------------------------------------------

void RingBuffer::markFramesWritten(BellSize numFrames)
{
    assert(numFrames <= availableWriteFrames());
    
    BellSize bytes = _bytesPerFrame * numFrames;
    
    _headPos = (_headPos + bytes) % _lengthInBytes;
    OSAtomicAdd64Barrier(+(int64_t)bytes, &_fillCountInBytes);
}

//---------------------------------------------------------------------

BellSize RingBuffer::readFromBuffer(BellSample *L, BellSample *R, BellSize const numFrames)
{
    // Get the size to read capped at the amount available
    BellSize numBytes = _bytesPerFrame * numFrames;
    BellSize availBytes = (_fillCountInBytes);
    numBytes = numBytes < availBytes ? numBytes : availBytes;
    
    // Grab the buffers and copy the data
    BellSample *readL, *readR;
    grabReadBuffer(&readL, &readR);
    memcpy(L, readL, numBytes);            //  @TODO accelerate?
    if (R)
        memcpy(R, readR, numBytes);
    
    // Mark them read
    BellSize framesRead = numBytes / _bytesPerFrame;
    markFramesRead(framesRead);
    
    // Return the actual amount written
    return framesRead;
}

//---------------------------------------------------------------------

BellSize RingBuffer::writeIntoBuffer(BellSample const *L, BellSample const *R, BellSize const numFrames)
{
    // Get the size to write capped at the amount remaining
    BellSize numBytes = _bytesPerFrame * numFrames;
    BellSize remainingBytes = (_lengthInBytes - _fillCountInBytes);
    numBytes = numBytes < remainingBytes ? numBytes : remainingBytes;
    
    // Grab the buffers and copy the data
    BellSample *writeL, *writeR;
    grabWriteBuffer(&writeL, &writeR);
    memcpy(writeL, L, numBytes);            //  @TODO accelerate?
    if (R)
        memcpy(writeR, R, numBytes);
    
    // Mark them written
    BellSize framesWritten = numBytes / _bytesPerFrame;
    markFramesWritten(framesWritten);
    
    // Return the actual amount written
    return framesWritten;
}




#endif