/**

idea here is that we have a general problem that we want to use delegtes but they dont work that well with 
objects and scopes.

usage:

cb = new GenericDelegate();
cg.callback.connect(() =>{
  do something
});
call_something(str ,str, cb)

This means that we can pass around a delegate, rather than fixing it to a object.

*/

class GenericDelegate