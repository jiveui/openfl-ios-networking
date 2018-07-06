#ifndef IOSNETWORKING_H
#define IOSNETWORKING_H


namespace iosnetworking {

	void httpRequest(int eventDispacherId, const char *url,  const char *method, const char *headerJson, const char *parametersJson);
	
}


#endif