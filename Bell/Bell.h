//
//  Bell.h
//  MantraCraft
//
//  Created by Hari Karam Singh on 18/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import "BellDefs.h"
#import "BellExceptions.h"
#import "BellSession.h"
#import "BellUtils.h"
#import "BellAudioFile.h"

// AUs are all Obj-C++ so only import if compatible
#ifdef __cplusplus
#import "c++/AtomicTypes.h"
#import "c++/RingBuffer.h"
#import "c++/BufferPool.h"
#import "modules/AUFilePlayer.h"
#import "modules/AUReverb2.h"
#import "modules/FileRecorder.h"
#endif