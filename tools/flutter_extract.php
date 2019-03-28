<?php

// in flutter - an event is actually a property..?

// we have 2 types of data - the overall summary, and the 'detail one we use for docs..
//

define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');


class Obj {
    
    static $out_props = array(
        'eClass' => array('props', 'events', 'methods'),
        'eMixin' =>  array('props', 'events', 'methods'),
        'eTypedef' => array('name', 'type', 'sig', 'static', 'desc','memberOf'),
        'eProperty' => array('name', 'type', 'desc','memberOf'),
        'eConstant' => array('name', 'type', 'desc','memberOf'),
        'eMethod' => array('name', 'type', 'sig', 'static', 'desc','memberOf', 'isConstructor'),
        'eConstructor' => array('name', 'type', 'sig', 'static', 'desc','memberOf', 'isConstructor'),
        'eEnum' =>  array('name', 'type',   'desc','memberOf'), // fixme .. .values.?
        'eFunction' =>  array('name', 'type', 'sig', 'static', 'desc','memberOf', 'isConstructor'),// fixme .. .memberof == package.
        'Prop' => array('name', 'type', 'desc','memberOf'),
    );
    
    var $href = '';
    var $desc = '';
    var $example = '';
    var $isDeprecated = false;
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
        echo "Reading : {$this->href}\n";
        $dom->loadHTMLFile(FDIR . $this->href);
        libxml_clear_errors();
        $xp = new DomXPath($dom);
        $desc = $this->getElementsByClassName($dom, 'desc');
        if ($desc->length) {
            $this->desc = $this->innerHTML($desc->item(0));
        }
        $sc = $this->getElementsByClassName($dom, 'source-code');
        if ($sc->length) {
            $this->example = $this->innerHTML($sc->item(0));
        }
        return $dom;
    }
    
    function getElementsByClassName($dom, $class)
    {
        $xp = new DomXPath($dom);
        return $xp->query("//*[contains(concat(' ', @class, ' '), ' ".$class." ')]");
    }
    function innerHTML($node)
    {
        if (!$node) {
            print_r($this); 
        }
        $dom= $node->ownerDocument;
        $ret = '';
        foreach ($node->childNodes as $child) 
        { 
            $ret.= $dom->saveHTML($child);
        }
        return $ret;
        
    }
    function parseType($sp)
    {
        if (!$sp) {
            print_R($this);
            echo "parseType got invalid value";
         }
        $ar = $sp->getElementsByTagName('a');
        if (!$ar->length) {
            $this->type = $sp->textContent;
        }
        if ($ar->length == 1) {
            $this->type = eClass::$url_map[$ar->item(0)->getAttribute('href')]->name;
            return;
        } 
        $this->types = array();
        $t = '';
        for($i =0;$i<$ar->length;$i++) {
            $add = eClass::$url_map[$ar->item($i)->getAttribute('href')]->name;;
            $this->types[] = $add;
            if ($i == 0) {
                $t .= ($i == 0) ? $add : (' <'. $add );
            }
        }
        for($i =0;$i<$ar->length-1;$i++) {
            $t .= '>';
        }
        $this->type = $t;
        
         
    }
    function toSummaryArray()
    {
        $ret = array();
        if (!isset(self::$out_props[get_class($this)] )) {
            die("don't know how to handle class: " . get_class($this));
        }
        foreach(self::$out_props[get_class($this)] as $k) {
            $out = $this->{$k};
            if (is_array($out)) {
                $out = array();
                foreach($this->{$k} as $v) {
                    $out[] = $v->toSummaryArray();
                }
            }
            $ret[$k] = $out;
        }
        return $ret;
    }
    
}

class Ns extends Obj {
    static $tree = array();
    static $kv = array();
    var $name = '';
    var $href = '';
    var $cn = array();
    function __construct($ar)
    {
        parent::__construct($ar);
        self::$tree[] = $this;
        self::$kv[$this->name] = $this;
    }
    static function add($cls)
    {
        self::$kv[$cls->memberOf]->cn[] = $cls;
    }
    function toTreeArray()
    {
        $ret = array(
            'name' => $this->name,
            'is_class' => false,
            'cn' => array()
        );
        // in theory flutter has a flat tree... ?
        foreach($this->cn as $e) {
            if (is_a($e, 'eClass') || is_a($e, 'eMixin')) {
                $ret['cn'][] = $e->toTreeArray();
            }
        }
        return $ret;
    }
}


class eClass extends Obj {
    
    static $all = array();
    static $url_map = array();
    var $name;
    var $extends;
    var $memberOf; /// really the package..
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
        Ns::add($this);
    }
    
    function parseHTML()
    {
        // do children first..
        
        
        
        $dom = parent::parseHTML();
        $dl = $dom->getElementsByTagName('dl')->item(0);
        if ($dl->getAttribute('class') != 'dl-horizontal') {
            $this->extends = '';
        } else {
            $dd = $dl->getElementsByTagName('a');
            if (!$dd->length) {
                if (strpos($this->innerHTML($dl), '@deprecated')) {
                    $this->isDeprecated = true;
                    return;
                }
                return;  // appears that the 'Annotation area' is used for things like @immutable etc..
            
                //echo "got dl-horizontal - but no 'a' tags";
                //print_R($this);exit;
            }
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
        foreach($this->events as $e) {
            $e->parseHTML();
        }
        foreach($this->methods as $e) {
            $e->parseHTML();
        }
        foreach($this->props as $e) {
            $e->parseHTML();
        }
        // loop through children.
        
    }
    function toTreeArray()
    {
        return array(
            'name' => $this->name,
            'is_class' => true,
            'cn' => array()
        );
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
    var $type = '';
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}
class eEnum extends eClass
{
    var $type = '';
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}

class eProperty extends eClass
{
    var $type = '?';
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
        for($i =0;$i<$ar->length;$i++) {
            $this->params[] = new Param( $ar->item($i) );
        }
        
        return $dom;
    }
    
}
class eConstructor extends eMethod {
    function parseHTML()
    {
        
        $dom = Obj::parseHTML();
        // doesnt have a 'type'    
        // params...
        $ar = $this->getElementsByClassName($dom,'parameter');
        for($i =0;$i<$ar->length;$i++) {
            $this->params[] = new Param( $ar->item($i) );
        }
        
        return $dom;
    }
}


class  eFunction extends eMethod
{
    function __construct($ar)
    {
        parent::__construct($ar);
        eClass::$all[$this->name] = $this;
        eClass::$url_map[$this->href] = $this;
        Ns::add($this);
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
class eTypedef extends eFunction
{
     
}
class Param extends Obj {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $isOptional = true;
    function __construct($node)
    {
        
        $ar  = $node->getElementsByTagName('span');
        if (!$ar->length) {
            echo "mssing paramter info", $this->innerHTML($node); exit;
        }
        for($i = 0; $i < $ar->length; $i++) {
            
            switch($ar->item($i)->getAttribute('class')) {
                case 'parameter-name':
                    $this->name = $ar->item($i)->textContent;
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
    if ($o->name == "charcode") {
        print_r($o);
        exit;
    }
    
    switch($o->type) {
        case 'library':
            new Ns(array(
                'name' => $o->name,
                'href' => $o->href
            ));
             
            break;
            
        case 'class':
        case 'mixin':
        case 'enum':
        case 'typedef': // func sig?
        case 'top-level property':
            $ctor = 'e'. ucfirst(str_replace('top-level ', '', $o->type));
            
            
            new $ctor(array(
                'name' => $o->qualifiedName,
                'href' => $o->href,
                'isMixin' => $o->type == 'mixin',
                'isEnum' => $o->type == 'enum',
                'isTypedef' => $o->type == 'typedef',
                'isConstant' => $o->type == 'top-level constant',
                'memberOf' => $o->enclosedBy->name,
                'dtype' => $o->type,
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
        
        case 'top-level constant':        
        case 'constant':
             $ar = explode('.', $o->qualifiedName);
            array_pop($ar);
            $memberof= implode('.', $ar);
            
            $add =  new eConstant(array(
                'name' => $o->name,
                'href' => $o->href,
                'memberOf' => $memberof,
            ));
            switch($o->enclosedBy->type) {
                case 'class':
                    if (empty(eClass::$all[$memberof])) {
                        print_r($o);
                        echo "Can not find class: $memberof to add object to";
                        exit;
                    }
                    eClass::$all[$memberof]->props[] = $add;
                    break;
                
                case 'library':
                    Ns::add($add);
                    break;
                
                default:
                    print_R($o);
                    exit;
                
            }
            break;
            
        case 'property':
        

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
            
            eClass::$all[$cls]->props[] = $add;
        
            break;  
        default:
            print_R($o);
            die("invalid type {$o->type}");
    }
    
    
    
}
$summary = array();
if (!file_exists(FDIR .'json')) {
    mkdir(FDIR .'json', 0755);
}


foreach(eClass::$all as $c) {
    if (!method_exists($c, 'readDocs')) {
        echo "missing readDocs";
        print_R($c);exit;
    }
    $c->readDocs();
    $summary[$c->name] = $c->toSummaryArray();
    if (is_a($c, 'eClass') ||is_a($c, 'eMixin') ) {
        file_put_contents(FDIR .'json/'.$c->name. '.json', json_encode($c,JSON_PRETTY_PRINT));
    }
    // constant's and other mixins.. 
}
$tree = array();
foreach(Ns::$tree as $e) {
    $tree[] = $e->toTreeArray();
}
file_put_contents(FDIR .'json/tree.json', json_encode($tree, JSON_PRETTY_PRINT));
//file_put_contents(FDIR .'json/index.json', json_encode($summary, JSON_PRETTY_PRINT)); // this is for builder.. later..

//print_r(eClass::$all);