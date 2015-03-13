//
//  BellBufferPool.m
//  SW-Guitar
//
//  Created by Hari Karam Singh on 08/03/2015.
//
//

#include "BufferPool.h"

using namespace bell;

BufferPool::BufferPool(BellSize bufferLengthInFrames, BellSize initialPoolSize)
{
    info("BufferPool init'ed with %i buffers of size %i (frames)", (int)initialPoolSize, (int)bufferLengthInFrames);
    
    _availableBuffers = std::stack<RingBuffer *>();
    _lockSemaphore = [NSObject new];
    
    // Pre-create the actual RingBuffers
    for (int i=0; i<initialPoolSize; i++)
    {
        RingBuffer *buff = new RingBuffer(bufferLengthInFrames);
        _availableBuffers.push(buff);
    }
    
    _bufferLengthInFrames = bufferLengthInFrames;
}

//---------------------------------------------------------------------

BufferPool::~BufferPool()
{
    drainPool();
}

//---------------------------------------------------------------------

RingBuffer *BufferPool::getAFreeBuffer()
{
    @synchronized(_lockSemaphore)
    {
        RingBuffer *bufferToRtn;
        
        // Create a new one if we are out. Otherwise pop the top one of the stack
        if (_availableBuffers.empty())
        {
            bufferToRtn = new RingBuffer(_bufferLengthInFrames);
            // but not the available as we're about to use it
            warn("Created new RingBuffer at %p", bufferToRtn);
        }
        else
        {
            bufferToRtn = _availableBuffers.top();
            _availableBuffers.pop();
            info("Recycling RingBuffer at %p (%i remaining)", bufferToRtn, (int)_availableBuffers.size());
        }
        
        // Reset it just in case
        bufferToRtn->clear();
        
        return bufferToRtn;
    }
}

//---------------------------------------------------------------------

void BufferPool::returnBufferToPool(bell::RingBuffer *buffer)
{
    @synchronized(_lockSemaphore)
    {
        info("Returning RingBuffers %p to Pool", buffer);
        buffer->clear();
        _availableBuffers.push(buffer);
    }
    
}

//---------------------------------------------------------------------

void BufferPool::drainPool()
{
    // Lock here to prevent deallocate when a another thread is accessing
    @synchronized(_lockSemaphore)
    {
        info("Draining Buffer Pool of %i RingBuffers", (int)_availableBuffers.size());
        // Erase the buffers. Clear out the remaining first but dont delete as they are the same underlying buffers
        while (auto entry = _availableBuffers.top())
        {
            _availableBuffers.pop();
            delete entry;
        }
    }
}