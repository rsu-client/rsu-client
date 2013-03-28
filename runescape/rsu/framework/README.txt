This folder contains the framework for the API.
It is basically the exposed functions from the rsu-client!

To keep things clean and organized the framework is split into sections
and sub sections which will be explained here.

./API = the API folder, it contains API calls
./framework = the framework folder, it is the ROOT of the framework
./modules = the modules folder, nothing shall be placed here
./modules/section = a section folder, init loaders and environment modules are located here
./modules/section/subsection = a subsection folder, it contains modules for specific tasks

API EXPLAINATION:
Each folder is considered part of an API call
the folder get corresponds to "get."
the file get/client/language.pm where get and client are folders and language.pm
is the API call handler, would be the same as calling rsu-query "get.client.language"

Whenever a .pm file is placed somewhere within the API folder, it will be considered an API call
which can be called through the rsu-query(for non perl languages) or through use, require or eval
in perl if you added the API folder to your @INC by using 'eval "use lib \"path\";'

API calls should do as little work as possible and instead use functions from the framework.


MODULES EXPLAINATION:
./modules/client
^
contains the client init module which initializes all modules needed by the client itself
and modules that deal with stuff that most other modules specific to the client itself uses
like environment variables containing the users home/profile directory.

./modules/client/settings
^
contains modules that deals with settings handling for the client
like the client language setting and parameter settings.



FAQ:
Q:	Why are rsu and client split up when they are both part of the client?
A:	The rsu section contains modules that are specific to the rsu client framework
	while the client section contains modules that are essential for the client
	core/jagexappletviewer itself.
	The only exception is the init module which just initializes the rsu-client environment
	when called by client.launch.runescape
	
Q:	Why an API/Framework?
A:	Simplifies my life and it also opens up for people to get functionality from
	the rsu project if they decide to make their own client or wrapper.
	
Q:	Will it inpact my own clients speed?
A:	Yes it will, since it is using a bridge (rsu-query) to let you fetch info from
	the rsu framework, however the idea of this was more to let people use this
	as the basis of their client while they work on their own native implementation.
	The sources are documented pretty well with the comments so you should be able
	to use the perl sources as a cookbook even if you dont know perl!
	
Q:	Why does the rsu-query just launch a binary file or a perl script file?
A:	It is bridging the query over to the actual rsu-query which comes in 2 versions.
	The binary version is slightly slower but you will be guaranteed to have all
	the core functionality, if a binary is not found it will use the perl script version
	which is faster as its using the system perl, however functions are dependent that
	the user have the required modules installed (in the case of Wx modules the
	script will warn the user that the GUI scripts might not work and it will tell
	if the Wx modules are missing)

Q:	Can i force the rsu-query to use the faster perl script version if i
	know the system got everything needed for the api call?
A:	Yes you can, just pass --unixquery as the last parameter in the call.
	This will force the query to be done in the system installed perl
	and it will not print to STDERR that it is running in fallback mode.
	
Q:	Will you ever ditch perl and move over to "insert programming/script language here"
A:	No, perl is very easy to code in and i can do several things easier than on other
	languages. I do however know that Fallen_Unia is porting the client to C so you can
	check that out.
	
Q:	With the project now being an API/Framework instead, does this mean
	the rsu-client is discontinued? :(
A:	No it is not discontinued, infact it is built into the API but it is
	not a direct part of the API.
	The script files are contained inside API/client/launch and the resources
	are contained inside resources/client/launch/$scriptname/
	And the scripts are using the API directly for maximum speed!
	If you do not need any of them you can freely delete them from the API though.
