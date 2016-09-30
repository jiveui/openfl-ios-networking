#ifndef OPENFLIOSNETWORKING_H
#define OPENFLIOSNETWORKING_H

namespace openfl_ios_networking {
	void httpRequest(int eventDispacherId, const char *url,  const char *method, const char *headerJson, const char *parametersJson);
}

#endif
