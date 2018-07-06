#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"


using namespace iosnetworking;



static void openfl_ios_networking_http_request (value eventDispatcherIdValue, value urlValue, value methodValue, value headerValue, value parametersValue) {
	httpRequest(val_int(eventDispatcherIdValue), val_string(urlValue), val_string(methodValue), val_string(headerValue), val_string(parametersValue));
}
DEFINE_PRIM (openfl_ios_networking_http_request, 5);



extern "C" void iosnetworking_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (iosnetworking_main);



extern "C" int iosnetworking_register_prims () { return 0; }