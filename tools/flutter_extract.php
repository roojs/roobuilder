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
      
        $this->desc = $dom->saveHtml($this->getElementsByClassName($dom, 'desc')->item(0));
        return $dom;
    }
    
    function getElementsByClassName($dom, $class)
    {
        $xp = new DomXPath($dom);
        return $xp->query("//*[contains(@class, '".$class."')]");
    }
    function parseType($sp)
    {
        $ar = $sp->getElementsByTagName('a');
        if ($ar->length == 1) {
            $this->type = eClass::$url_map[$ar->item(0)->getAttribute('href')]->name;
        } else {
            $this->type = array();
            for($i =0;$i<$ar->length;$i++) {
                $this->type[] = eClass::$url_map[$ar->item($i)->getAttribute('href')]->name;
            }
        }
    }
}


class eClass extends Obj {
    
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
    
    function parseHTML()
    {
        
        $dom = parent::parseHTML();
        $dl = $dom->getElementsByTagName('dl')->item(0);
        if ($dl->getAttribute('class') != 'dl-horizontal') {
            $this->extends = '';
        } else {
            $dd = $dl->getElementsByTagName('a');
            
            if (!isset(self::$url_map[$dd->item($dd->length-1)->getAttribute('href')])) {
                die("could not find " . $dd->item($dd->length-1)->getAttribute('href') . " when parsing" . $this->href);
            }
            
            // 
            
            $this->extends = self::$url_map[$dd->item($dd->length-1)->getAttribute('href')]->name;
        }
        
    }
    
    function readDocs()
    {
        $this->parseHTML();
        // loop through children.
        
    }
    
}
class eMixin extends eClass
{
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}
class eConstant extends eClass
{
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}
class eEnum extends eClass
{
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}
class eTypedef extends eClass
{
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}
class  Prop extends Obj {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $memberOf = '';
    var $isConstant = false;
}

class  eMethod extends Obj {  // doubles up for events? - normally 'on' is the name
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
    function parseHTML()
    {
        $dom = parent::parseHTML();
        $sp = $this->getElementsByClassName($dom,'returntype')->item(0);
        $this->parseType($sp);
        
        // params...
        $ar = $this->getElementsByClassName($dom,'parameter');
        for($i =0;i<$ar->length;$i++) {
            $this->params[] = new Param( $ar->item($i) );
        }
        
        return $dom;
    }
    
}
class eConstructor extends eMethod {
    
}


class  eFunction extends eMethod
{
    function __construct($ar)
    {
        parent::__construct($ar);
        eClass::$all[$this->name] = $this;
        eClass::$url_map[$this->href] = $this;
    }
    function readDocs()
    {
        $this->parseHTML();
        // loop through children.
        
    }
    function parseHTML()
    {
        
        $dom = parent::parseHTML();
    }
}

class Param extends Obj {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $isOptional = true;
    function __construct($node)
    {
        $ar  = $node->getElementsByTagName('span');
        for($i = 0; i < $ar->length; $i++) {
            
            switch($ar->item($i)->getAttribute('class')) {
                case 'parameter-name':
                    $this->name = $ar->item($i)->innerHTML();
                    break;
                case 'type-annotation':
                     $this->parseType($ar->item($i));
                    break;
                
            }
        }
        
        
        
    }
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
       
            $ctor = 'e'. ucfirst(str_replace('top-level ', '', $o->type));
            
            
            new $ctor(array(
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
            $ctor = 'e'. ucfirst($o->type);
            $add = new $ctor(array(
                'name' => $o->name,
                'href' => $o->href,
                'isConstructor' => $o->type == 'constructor',
            ));
            if ($o->type != 'function') {
                eClass::$all[$cls]->methods[] = $add;
            } else {
                eClass::$all[$o->qualifiedName] = $add;
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
                eClass::$all[$cls]->events[] = new eMethod(array(
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
                eClass::$all[$o->qualifiedName] = $add;
            } else {
                eClass::$all[$cls]->props[] = $add;
            }
            break;  
        default:
            print_R($o);
            die("invalid type {$o->type}");
    }
    
    
    
}
 
foreach(eClass::$all as $c) {
    if (!method_exists($c, 'readDocs')) {
        print_R($c);exit;
    }
    $c->readDocs();
}

print_r(eClass::$all);