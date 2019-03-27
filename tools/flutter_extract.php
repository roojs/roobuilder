<?php

// in flutter - an event is actually a property..?

// we have 2 types of data - the overall summary, and the 'detail one we use for docs..
//

define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');


class Obj {
    var $href = '';
    function __construct($ar)
    {
        foreach($ar as $k=>$v) {
            $this->{$k} = $v;
        }
         
    }
    
    
    function parseHTML()
    {
        $dom = new DomDocument(); 
        $dom->loadHTMLFile(FDIR . $this->href);
        $this->desc = $dom->saveHtml($dom->getElementsByClassName('desc')->item(0));
        return $dom;
    }
}
class Cls extends Obj {
    
    static $all = array();
    static $url_map = array();
    var $name;
    var $extends;
    var $events = array();
    var $methods = array();
    var $props = array();
    
    function __construct($ar)
    {
        parent::__construct($ar);
        self::$all[$this->name] = $this;
        self::$url_map[$this->href] = $this;
    }
    
    function parseHTML() {
        
        $dom = parent::parseHTML();
        $dl = $dom->getElementsByTagName('dl')->item(0);
        $dd = $dl->getElementsByTagName('a');
        $this->extends = self::$url_map[$dd->item($dd->length-1)->getAttribute('href')]->name;
        
    }
    
    function readDocs()
    {
        $this->parseHTML();
        // loop through children.
        
    }
    
}
class  Prop extends Obj {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $memberOf = '';
}

class  Method extends Obj {  // doubles up for events? - normally 'on' is the name
    var $name = '';
    var $type = ''; // return...
    var $desc = '';
    var $static = false;
    var $memberOf = '';
    var $sig = '';
    var $params  = array();
    
      //"isStatic" : false,
    var $isConstructor = false;
    //"example" : "",
    //  "deprecated" : "",
    //  "since" : "",
     // "see" : "",
    // return_desc
    
}


class Param extends Obj {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $isOptional = true;
}



$js = json_decode(file_get_contents(FDIR.'index.json'));

foreach($js as $o) {
    switch($o->type) {
        case 'library':
            break;
            
        case 'class':
            new Cls(array(
                'name' => $o->qualifiedName,
                'href' => $o->href
            ));
            break;
        
        case 'method':
            $ar = explode('.', $o->qualifiedName);
            array_pop($ar);
            $cls = implode('.', $ar);
          
            
            Cls::$all[$cls]->methods[] = new Method(array(
                'name' => $o->name,
                'href' => $o->href,
            ));
            break;
        
        case 'property':
            $ar = explode('.', $o->qualifiedName);
            array_pop($ar);
            $cls = implode('.', $ar);
            if (substr($o->name, 0,2) == 'on') {
                // presumtionus...
                Cls::$all[$cls]->events[] = new Method(array(
                    'name' => $o->name,
                    'href' => $o->href,
                    
                ));
                break;
            }
            
            Cls::$all[$cls]->props[] = new Prop(array(
                'name' => $o->name,
                'href' => $o->href,
            ));
            break;  
           
    }
    
    
    
}
 
foreach(Cls::$all as $c) {
    $c->readDocs();
}

print_r(Cls::$all);