package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end

import haxe.ds.StringMap;
import haxe.Json;
import openfl.events.EventDispatcher;
import openfl.events.Event;
import extensionkit.ExtensionKit;

class IOSNetworkingEvent extends Event {
	public static inline var COMPLETE = "openfl_ios_networking_complete";

	public var data(default, null): String;
	public var error(default, null): String;

    public function new(type: String, data: String, error: String) {
    	this.data = data;
    	this.error = error;
        super(type, true, true);
    }
}

class IOSNetworkingEventDispatcher extends EventDispatcher {
	public dynamic function onData( data : String ) {}
	public dynamic function onError( msg : String ) {}
	public dynamic function onStatus( status : Int ) {}

	public var eventDispatcherId(default, null):Int = 0;

	public function new() {
		super();
        this.eventDispatcherId = ExtensionKit.RegisterEventDispatcher(this);
        addEventListener(IOSNetworkingEvent.COMPLETE, function(e: Dynamic) {
        	// trace(e);
        	if (e.error == "SUCCESS") {
        		onData(e.data);
        	} else {
        		onError(e.error);
        	}
        });
	}
}

class IOSNetworking {

	private static var s_initialized:Bool = false;

    public static function Initialize() : Void
    {
        if (s_initialized)
        {
            return;
        }

        s_initialized = true;
        ExtensionKit.Initialize();
    }	

	public static function httpRequest(url: String, method: String, header: StringMap<String>, parameters: StringMap<String>, onData: String -> Void, onError: String -> Void) {

		Initialize();

		var d = new IOSNetworkingEventDispatcher();
		d.onData = onData;
		d.onError = onError;

		// trace("Header: " + Json.stringify(header, null, "    "));
		// trace("Parameters: " + Json.stringify(parameters, null, "    "));

		return openfl_ios_networking_http_request(d.eventDispatcherId, url, method, Json.stringify(header, null, "    "),  Json.stringify(parameters, null, "    "));
	}
	
	
	private static var openfl_ios_networking_http_request = Lib.load ("openfl_ios_networking", "openfl_ios_networking_http_request", 5);
	
	#if (android && openfl)
	private static var openfl_ios_networking_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.Openfl_ios_networking", "sampleMethod", "(I)I");
	#end
	
	
}