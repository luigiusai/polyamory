# polyamory - multi version LÖVE

polyamory is a compilation of [LÖVE](https://love2d.org) runtimes that combines several LÖVE versions into one. It can run games that have been written for a wide range of LÖVE API versions with a single, unified and easy to use program.

polyamory consists of a bunch of new and old binary releases, put together with a bit of Lua glue, in a horribly inefficient and bloated way.

It is not intended for developers, but rather meant to be used as a drop-in replacement by players who want to play older and newer LÖVE games on their Windows or Linux computers without the hassle of worrying about what LÖVE version the game requires.

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

## Downloads

SOON!

## How to use

**Windows**: polyamory is a drop-in replacement for an existing LÖVE installation. Make a backup copy of your current LÖVE installation directory and replace the original with the directory from the downloaded polyamory archive.

**Linux**: put the polyamory binary in your search path. Start love games by typing `polyamory <game>.love` in a terminal window.

## Build instructions

### Linux

You need one AppImage for each version of LÖVE you want to include in your build. Check the [LÖVE](https://bitbucket.org/rude/love) repo for build scripts and instructions.

Other requirements:  

* bash to run the build script
* appimagetool in your PATH. Any non-ancient version of AppImageKit will probably do.  

#### Step 1  

Copy the AppImage of the *latest* release image into the `linux/x64`/`x86` directory, and name it `base.image`:

    linux/  
        x64/
            base.image  <-- here
            love/  

#### Step 2  

Make a directory for each LÖVE version you want to include in your build in `linux/x64/love` or `linux/x86/love`, depending on the platform you want to build for. Name each directory exactly the same as the version string of the LÖVE version that will go in there:

    linux/  
        x64/  
            base.image  
            love/  
                11.1/   <-- here  
                11.0/   <-- here  
                0.9.0/  <-- here  
                ...  

#### Step 3  

Place your pre-built images in the numbered directory structure you have created, according to the LÖVE release they contain, and rename them as `love.exe`:

    linux/  
        x64/  
            base.image
            love/  
                11.1/  
                    love.exe  <-- here  
                11.0/  
                    love.exe  <-- here  
                0.9.0/  
                    love.exe  <-- here  
                ...  

#### Step 4  

Run this command from the `linux` directory:

    $ bash build x64 # or sh build x86, depends on your target platform

#### Done

If all went well, you'll find a polyamory executable in `build/linux/x64` or `build/linux/x86`, respectively.

---

### Windows

**Note**: You can only build polyamory *for* Windows, but there is no script to build it *on* Windows. If you want to build it on Windows, you can read the `windows/build` file and do the required steps manually.

Requirements:

* bash to run the build script

#### Step 1  

Build each LÖVE version you want to include, or download pre-built zips with binaries for each version and architecture you want to include from the [LÖVE repo](https://bitbucket.org/rude/love/downloads) (e. g. `love-$VERSION-win<32 or 64>.zip`)

#### Step 2  

For each version to be included, create a directory in `windows/x64` or `windows/x86`. Name each directory exactly the same as the version string of the LÖVE version that will go in there:

    windows/  
        x64/  
            love/  
                11.1/   <-- here  
                11.0/   <-- here  
                0.9.0/  <-- here  
                ...  

Copy the files for each version into these directories.

#### Step 3  

Build or download the latest LÖVE version and put the files for that version in `windows/x64` or `windows/x86`:

    windows/  
        x64/  
            love.exe    <-- here
            readme.txt  <-- here
            ...
            love/  
                11.1/  
                11.0/  
                0.9.0/  
                ...  

#### Step 4  

Run this command from the `windows` directory:

    $ bash build x64 # or sh build x86, depends on your target platform

#### Done

If all went well, the built files can be found in `build/windows/x64` or `build/windows/x86`, respectively.
