//
//  BellRingBuffer.m
//  SW-Guitar
//
//  Created by Hari Karam Singh on 08/03/2015.
//
//

#include <mach/mach.h>
#include "RingBuffer.h"

using namespace bell;

//---------------------------------------------------------------------

#define checkResult(result,operation) (_checkResult((result),(operation),strrchr(__FILE__, '/'),__LINE__))
static inline bool _checkResult(kern_return_t result, const char *operation, const char* file, int line) {
    if ( result != ERR_SUCCESS ) {
        printf("%s:%d: %s: %s\n", file, line, operation, mach_error_string(result));
        return false;
    }
    return true;
}

//---------------------------------------------------------------------

RingBuffer::RingBuffer(BellSize lengthInFrames)
{
    _bytesPerFrame = sizeof(BellSample);
    
    _lengthInBytes = round_page(lengthInFrames * _bytesPerFrame);   // We need whole page sizes for the virtual memory tricl
    _bufferL = (BellSample *)_allocateBuffer(_lengthInBytes);
    _bufferR = (BellSample *)_allocateBuffer(_lengthInBytes);
    _fillCountInBytes = 0;
    _headPos = _tailPos = 0;
}

//---------------------------------------------------------------------

RingBuffer::~RingBuffer()
{
    vm_deallocate(mach_task_self(), (vm_address_t)_bufferL, _lengthInBytes * 2);
    vm_deallocate(mach_task_self(), (vm_address_t)_bufferR, _lengthInBytes * 2);
}

//---------------------------------------------------------------------

void *RingBuffer::_allocateBuffer(BellSize sizeInBytes)
{
    // Temporarily allocate twice the length, so we have the contiguous address space to
    // support a second instance of the buffer directly after
    vm_address_t bufferAddress;
    if ( !checkResult(vm_allocate(mach_task_self(), &bufferAddress, sizeInBytes * 2, TRUE /* (don't use the current bufferAddress value) */),
                      "Buffer allocation") ) throw 1;
    
    // Now replace the second half of the allocation with a virtual copy of the first half. Deallocate the second half...
    if ( !checkResult(vm_deallocate(mach_task_self(), bufferAddress + sizeInBytes, sizeInBytes),
                      "Buffer deallocation") ) throw 1;
    
    // Then create a memory entry that refers to the buffer
    vm_size_t entry_length = sizeInBytes;
    mach_port_t memoryEntry;
    if ( !checkResult(mach_make_memory_entry(mach_task_self(), &entry_length, bufferAddress, VM_PROT_READ|VM_PROT_WRITE, &memoryEntry, 0),
                      "Create memory entry") ) {
        vm_deallocate(mach_task_self(), bufferAddress, sizeInBytes);
        throw 1;
    }
    
    // And map the memory entry to the address space immediately after the buffer
    vm_address_t virtualAddress = bufferAddress + sizeInBytes;
    if ( !checkResult(vm_map(mach_task_self(), &virtualAddress, sizeInBytes, 0, FALSE, memoryEntry, 0, FALSE, VM_PROT_READ | VM_PROT_WRITE, VM_PROT_READ | VM_PROT_WRITE, VM_INHERIT_DEFAULT),
                      "Map buffer memory") ) {
        vm_deallocate(mach_task_self(), bufferAddress, sizeInBytes);
        throw 1;
    }
    
    if ( virtualAddress != bufferAddress+sizeInBytes ) {
        printf("Couldn't map buffer memory to end of buffer\n");
        vm_deallocate(mach_task_self(), virtualAddress, sizeInBytes);
        vm_deallocate(mach_task_self(), bufferAddress, sizeInBytes);
        throw 1;
    }
    
    return (void *)bufferAddress;
}

//---------------------------------------------------------------------

void RingBuffer::clear()
{
    _headPos = 0;
    _tailPos = 0;
}
