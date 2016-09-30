# haxe.HTTP implementation for the iOS target of the OpenFL framework

Now it implements only HTTP.request method and works only in the legacy mode. So newest versions are not supported.

## Usage

Install the libraries into the parent directory of the  OpenFl project.

``` 
git clone https://github.com/jiveui/extensionkit
git clone https://github.com/jiveui/openfl-ios-networking
```

put the lines into the project.xml

```
<include path="../extensionkit" if="ios" />
<include path="../openfl-ios-networking" if="ios" />
```

That's it.
