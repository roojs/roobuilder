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
        libxml_use_internal_errors(true);
        
        $dom->loadHTMLFile(FDIR . $this->href);
        libxml_clear_errors();
        $xp = new DomXPath($dom);
      
        $this->desc = $dom->saveHtml($xp->query("//*[contains(@class, 'desc')]")->item(0));
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
    var $isMixin = false;
    var $isEnum = false;
    var $isTypedef = false;
    var $isConstant = false;
    
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
    var $isConstant = false;
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
        case 'mixin':
        case 'enum':
        case 'typedef': // func sig?
        case 'top-level constant':
       
            
            
            
            new Cls(array(
                'name' => $o->qualifiedName,
                'href' => $o->href,
                'isMixin' => $o->type == 'mixin',
                'isEnum' => $o->type == 'enum',
                'isTypedef' => $o->type == 'typedef',
                'isConstant' => $o->type == 'top-level constant',
            ));
            break;
        
         
        
        case 'constructor':
        case 'method':
        case 'function':
            $ar = explode('.', $o->qualifiedName);
            array_pop($ar);
            $cls = implode('.', $ar);
          
            $add = new Method(array(
                'name' => $o->name,
                'href' => $o->href,
                'isConstructor' => $o->type == 'constructor',
            ));
            if ($o->type != 'function') {
                Cls::$all[$cls]->methods[] = $add;
            } else {
                Cls::$all[$o->qualifiedName] = $add;
            }
            break;
        
        case 'constant':
        case 'property':
        case 'top-level property':

            $ar = explode('.', $o->qualifiedName);
            array_pop($ar);
            $cls = implode('.', $ar);
            
            
            
            if (substr($o->name, 0,2) == 'on' && $o->type == 'property') {
                // presumtionus...
                Cls::$all[$cls]->events[] = new Method(array(
                    'name' => $o->name,
                    'href' => $o->href,
                    'isConstant' => $o->type == 'constant',
                    
                ));
                break;
            }
            $add =  new Prop(array(
                'name' => $o->name,
                'href' => $o->href,
            ));
            if ($o->type == 'top-level property') {
                Cls::$all[$o->qualifiedName] = $add;
            } else {
                Cls::$all[$cls]->props[] = $add;
            }
            break;  
        default:
            print_R($o);
            die("invalid type {$o->type}");
    }
    
    
    
}
 
foreach(Cls::$all as $c) {
    if (!is_a($c, 'Cls')) {
        print_R($c);
        continue;
    }
    $c->readDocs();
}

print_r(Cls::$all);