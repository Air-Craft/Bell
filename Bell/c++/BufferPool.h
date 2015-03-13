//
//  BellBufferPool.h
//  SW-Guitar
//
//  Created by Hari Karam Singh on 08/03/2015.
//
//
#ifndef bell_BufferPool
#define bell_BufferPool 1

#include <stack>
#include "BellDefs.h"
#include "RingBuffer.h"


namespace bell {
    
    /**
     A thread safe pool for creating and recycling RingBuffers
     
    NOTES:
     - Be sure to return all buffers before deconstruct or else you'll have a memory leak
     */
    class BufferPool
    {
/////////////////////////////////////////////////////////////////////////
#pragma mark - Ivars
/////////////////////////////////////////////////////////////////////////
    private:
        std::stack<RingBuffer *> _availableBuffers;
        BellSize _bufferLengthInFrames;
        id _lockSemaphore;   // our locking sema
        
/////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
/////////////////////////////////////////////////////////////////////////
        
    public:
        BufferPool() { throw 1; };
        BufferPool(BellSize bufferLengthInFrames, BellSize initialPoolSize);
        ~BufferPool();
        
        // Disables the other 2 in the rule of three as we'll only be using this in pointer form
    private:
        BufferPool(const BufferPool&);
        BufferPool& operator=(const BufferPool&);
        
        
/////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods
/////////////////////////////////////////////////////////////////////////
    public:
        
        RingBuffer *getAFreeBuffer();
        void returnBufferToPool(RingBuffer *buffer);
        
        /** Drains just the available buffers. Not the ones in use */
        void drainPool();
        
        
/////////////////////////////////////////////////////////////////////////
#pragma mark - Additional Privates
/////////////////////////////////////////////////////////////////////////
    private:
        
    };
}




#endif