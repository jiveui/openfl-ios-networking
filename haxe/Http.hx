package haxe;

import haxe.ds.StringMap;

#if ios
class Http {

	public var url : String;
	public var responseData(default, null) : Null<String>;
	public var cnxTimeout : Float;

	var postData : String;
	var headers : List<{ header:String, value:String }>;
	var params : List<{ param:String, value:String }>;

	public dynamic function onData( data : String ) {}
	public dynamic function onError( msg : String ) {}
	public dynamic function onStatus( status : Int ) {}

	public function new( url : String ) {
		this.url = url;
		headers = new List<{ header:String, value:String }>();
		params = new List<{ param:String, value:String }>();
		cnxTimeout = 10;
	}


	public function setHeader( header : String, value : String ):Http {
		headers = Lambda.filter(headers, function(h) return h.header != header);
		headers.push({ header:header, value:value });
		return this;
	}

	public function addHeader( header : String, value : String ):Http {
		headers.push({ header:header, value:value });
		return this;
	}
	public function setParameter( param : String, value : String ):Http {
		params = Lambda.filter(params, function(p) return p.param != param);
		params.push({ param:param, value:value });
		return this;
	}

	public function addParameter( param : String, value : String ):Http {
		params.push({ param:param, value:value });
		return this;
	}

	public function setPostData( data : String ):Http {
		postData = data;
		return this;
	}

	public function request( ?post : Bool, ?method: String ) : Void {
		var me = this;
		var old = onError;
		var err = false;
		if (null == method) method = if (post) "POST" else "GET";
		onError = function(e) {
			trace("Error: " + e);
			me.responseData = "";
			err = true;
			// Resetting back onError before calling it allows for a second "retry" request to be sent without onError being wrapped twice
			onError = old;
			onError(e);
		}
		// trace(url);
		// trace(method);
		IOSNetworking.httpRequest(url,
			method, 
			prepareHeaders(), 
			prepareParameters(), 
			function(data) {
				 // trace("Data: " + data);
				me.onData(me.responseData = data);	
			},
			onError);
	}

	private function prepareHeaders(): StringMap<String> {
		var res: StringMap<String> = new StringMap<String>();
		for (r in headers) {
			res.set(r.header, r.value);
		}
		return res;
	} 

	private function prepareParameters(): StringMap<String> {
		var res: StringMap<String> = new StringMap<String>();
		for (r in params) {
			res.set(r.param, r.value);
		}
		return res;
	} 

	// public static function requestUrl( url : String ) : String {
	// 	var h = new Http(url);
	// 	var r = null;
	// 	h.onData = function(d){
	// 		r = d;
	// 	}
	// 	h.onError = function(e){
	// 		throw e;
	// 	}
	// 	h.request(false);
	// 	return r;
	// }
}
#end