#include <jsc/jsc.h>
#include <glib.h>
#include <glib-object.h>
/**
 a wrapper around call as function, as Value[] arrays do not work in Vala...

*/


JSValueRef jscore_object_call_as_function(
	JSContextRef ctx,
	JSObjectRef object, 
	JSObjectRef thisObject,
	  gchar * val,
	JSValueRef* exception
	
) {
	JSValueRef  ex = 0;
	JSValueRef res;
    JSValueRef *jsargs;
    
    
    JSStringRef jsstr = JSStringCreateWithUTF8CString (val);
	JSValueRef valstr = JSValueMakeString (ctx, jsstr);
	//JSStringRelease (jsstr); //??
    
    jsargs = (JSValueRef *) g_newa (JSValueRef, 1);
    jsargs[0] =  valstr;
    
    res =  JSObjectCallAsFunction(
			ctx, 
			object, 
			0, 
			1, 
			jsargs, 
			&ex
	);
	// free the args..
	
    return res;

  
}
  
