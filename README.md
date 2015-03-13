# FUTURE NOTES #

- "AudioUnitRender can provide pointers to its own buffers."  Perhaps this is better for "generators" as it will spare a copy op?

- in process(), is it safe to render to L,R only?  Do we need to read the number of frames actually written?  Do they get zeroed?

- Should we get rid of the complex RCB since we're wrapping it for microphone data anyway? Instead just have a function (or block!) with numFrames, *L, *R, maybe inTimeStamp (as frames?).  What about pre/post render business?


# TODO #

- Typedef Bell_Size and cleanup (can frame ever be < 0?  Why the BellSize sometimes??)