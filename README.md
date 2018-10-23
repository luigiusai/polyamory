# polyamory - multi LÖVE

polyamory is a compilation of [LÖVE](https://love2d.org) runtimes that combines several LÖVE runtime versions into one. It can run games that have been written for a wide range of API versions with a single, unified executable.

It consists of a bunch of new and old binary releases, put together with a bit of Lua glue, in a horribly inefficient and bloated way.

polyamory is not intended for developers, but rather meant to be used as a drop-in replacement by players who want to play both older and newer LÖVE games on their Windows or Linux computers without having to worry about the LÖVE version the game was built for.

Currently supported LÖVE versions:

* 11.1
* 11.0
* 0.10.2
* 0.10.1
* 0.10.0
* 0.9.2
* 0.9.1
* 0.9.0
* 0.8.0

## How to use

On Linux: put the polyamory binary somewhere in your search path. Start love games by typing `polyamory <game>.love` in a terminal window.

On Windows: polyamory is a portable drop-in replacement of your current LÖVE installation. 

## Build instructions

### Linux

You need one AppImage for each version of LÖVE you want to include in your build. Check the [LÖVE](https://bitbucket.org/rude/love) repo for build scripts and instructions.

Other requirements:  

* bash  
* appimagetool in your PATH, any non-ancient version of AppImageKit will probably do.  

1. Copy the AppImage of the *latest* release image into the `linux/x64`/`x86` directory, and name it `base.image`:

    linux/  
      x64/
        love/  
          base.image  *  

2. Place your pre-built images in linux/x64/love or linux/x86/love, depending on the platform you want to build for.

Create one directory per LÖVE version. Name each directory exactly the same as the version string of the LÖVE version you're placing in there:

    linux/  
      x64/
       base.image
       love/  
          11.1/   *  
          11.0/   *  
          0.9.0/  *  
          ...  

3. Copy each AppImage into the numbered directory structure you have created, according to the LÖVE release they contain, and rename them `love.exe`:

    linux/  
      x64/
        love/  
          base.image  *  
          11.1/   
            love.exe  *  
          11.0/     
            love.exe  *  
          0.9.0/    
            love.exe  *  
          ...  

4. Run this command from the `linux` directory:

    $ sh build x64 # or sh build x86, depends on your target platform

#### Done

If all went well, you'll find a polyamory executable in build/linux/x64 or build/linux/x86, respectively.

### Windows

Coming soon!
