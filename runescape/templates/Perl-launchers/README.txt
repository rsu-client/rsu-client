These files are loaders written in perl that can be packaged with
the PAR::Packer module into executables that acts as local a
barebones compressed perl that does not need any installation
on the users end.
This approach is the simplest and most open out of the
perl redistribution approach and load scripts with a third-party perl
that the user have not compiled themselves, plus the introduction of 2
exe files on windows that are compiled in a separate language just to
launch the scripts in the third party perl…

However with the PAR::Packer approach the user can always decompile the
executables by simply appending .zip at the end of the executable names
and they will be able to extract ALL the source code for that executable!


For the settings_loader.pl we use wxpar from the Wx::Perl::Packager module.
This takes care of bundling the wxWidgets libraries within the executable
(and can be extracted along with the source if the user adds .zip at the
end of the executable name).
On MacOSX however you need to redistribute the library files as the
executable file is unable to load them from inside itself.
So you have to launch the wxpar packaged executable with DYLD_LIBRARY_PATH
to make it find the wxWidgets libraries.


However this 100% open approach sounds awesome and everything, but it has
3 drawbacks…
1. It takes longer to start up the executable than the closed approach
2. It caches the script inside %TEMP% on windows and $TEMP on Unix to make
future launches of the executable faster.
3. On windows, the system function and callback("backticks") function will
make the command prompt flash on the screen each time these functions are
used by the script if the loader was PAR packed with the -gui parameter,
you can avoid the command prompt flashes by not applying the -gui parameter, 
but it will instead cause the command prompt always be shown on the screen
to display script output or debug messages.

PS: only the settings_loader is needed on MacOSX/darwin