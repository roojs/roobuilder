<?php

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
             
            $t .= ($i == 0) ? $add : ('<'. $add );
             
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
    function isA($str)
    {
        return false;
    }
    
}

class Ns extends Obj {
    static $tree = array();
    static $kv = array();
    var $name = '';
    var $href = '';
    var $cn = array();
    var $isFakeNamespace = false;
    function __construct($ar)
    {
        parent::__construct($ar);
        
        if ($this->isFakeNamespace) {
            return;
        }
        
        $bits=  explode('.', $this->name);
        
        self::$kv[$this->name] = $this;
        
        if (count($bits) == 1 ) {
            self::$tree[] = $this;
            return;
        } 
        array_pop($bits);
        $par = implode('.', $bits);
        $this->memberOf = $par;
        self::add($this);
        
        
    }
    static function add($cls)
    {
        self::$kv[$cls->memberOf]->cn[] = $cls;
    }
    
    function fakeTree()
    {
         
        foreach($this->cn as $c) {
            if (!isset($c->shortname))  {
                continue;
            }
            $map[$c->shortname] = $c;
             
              
            
        }
        
        $cn = array();
        foreach($this->cn as $c) {
            if (!isset($c->shortname))  {
                continue;
            }
            $bits = preg_split('/(?<=[a-z])(?=[A-Z])|(?=[A-Z][a-z])/',
                                 $c->shortname, -1, PREG_SPLIT_NO_EMPTY);
            //print_r($bits);
            if (count($bits) < 2 ) {
                $cn[] = $c;
                continue;   
            }
            if (!isset($map[$bits[0]])) {
                $add = new Ns(array(
                    'name' => $c->memberOf .'.'. $bits[0],
                    'isFakeNamespace' => true,
                    
                ));
                $map[$bits[0]] = $add;
                $cn[] = $add;
            }
            
            $map[$bits[0]]->cn[] = $c;
            
        }
        
        // finally remove from tree if it's saving '1'
        $cc = array();
        foreach($cn as $c) {
            if (empty($c->isFakeNamespace)) {
                $cc[] = $c;
                continue;
            }
            if (count($c->cn) < 2) {
                $cc[] = $c->cn[0];
                continue;
            }
            $cc[] = $c;
            
        }
        
        $this->cn = $cc;
        
 
    }
    
    function toTreeArray()
    {
        // tidy the tree before starting...
        
        
        
        $ret = array(
            'name' => $this->name,
            'is_class' => false,
            'cn' => array()
        );
        // in theory flutter has a flat tree... ?
        foreach($this->cn as $e) {
           if (in_array(get_class($e) , array('eClass', 'eMixin', 'Ns'))) {
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
    var $extends = array();
    var $memberOf; /// really the package..
    var $events = array();
    var $methods = array();
    var $props = array();
    var $isMixin = false;
    var $isEnum = false;
    var $isTypedef = false;
    var $isConstant = false;
    var $isAbstract = false;
    var $implementors = array();
    var $realImplementors = array();
    var $cn = array();
    function __construct($ar)
    {
        parent::__construct($ar);
        $bits = explode('.', $this->name);
        $this->shortname  = array_pop($bits);
        
        self::$all[$this->name] = $this;
        self::$url_map[$this->href] = $this;
        Ns::add($this);
    }
    
    function parseHTML()
    {
        // do children first..
        
        
        
        $dom = parent::parseHTML();
        
        $sc = $this->getElementsByClassName($dom,'self-crumb');
        if ($sc->length) {
            // abstracts actually impletment stuff in flutter...
            if (preg_match('/abstract class/', $this->innerHTML($sc->item(0)))) {
                $this->isAbstract = true;
            }
             
        }
        
        
        
        $dl = $dom->getElementsByTagName('dl')->item(0);
        if ($dl->getAttribute('class') != 'dl-horizontal') {
            $this->extends = array();
            return;
        }
        
        if (strpos($this->innerHTML($dl), '@deprecated')) {
             $this->isDeprecated = true;
        }
        
        
        
        $dt = $dl->getElementsByTagName('dt');
        if (!$dt->length) {
            return;
        }
        if ($this->innerHTML($dt->item(0)) != 'Inheritance') {
            return;
        }
        
        $dd = $dl->getElementsByTagName('dd');
        if (!$dd->length) {
            return;
        }
        $as = $dd->item(0)->getElementsByTagName('a');
        $this->extends = array();        
        for($i = $as->length-1;$i > -1; $i--) {

            if (!isset(self::$url_map[$as->item($i)->getAttribute('href')])) {
                die("could not find " . $as->item($i)->getAttribute('href') . " when parsing" . $this->href);
            }
            
            $this->extends[] = self::$url_map[$as->item($i)->getAttribute('href')]->name;
            self::$url_map[$as->item($i)->getAttribute('href')]->addImplementor($this->name);
        }
        
        
        
         
        
    }
    function addImplementor($n)
    {
        if (!in_array($n, $this->implementors)) {
            $this->implementors[] = $n;
        }
    }
    function expandImplementors($exclude = array())
    {
        $exclude[] = $this->name;
        $add = array();
        $orig = $this->implementors;
        foreach($orig as $c) {
            if (in_array($c, $exclude)) {
                continue;
            }
            $cl = self::$all[$c]->expandImplementors($exclude);
            foreach($cl as $cc) {
                if (!in_array($cc, $this->implementors)) {
                    $this->implementors[]= $cc;
                }
            }
        }
        return $this->implementors;
        
    }
    function realImplementors()
    {
        
        $this->realImplementors  = array();
        foreach($this->implementors as $c) {
            if (self::$all[$c]->isAbstract) {
                return;
            }
            $this->realImplementors[] = $c;
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
        $cn = array();
        foreach($this->cn as $e) {
            if (in_array(get_class($e) , array('eClass', 'eMixin'))) {
                $cn[] = $e->toTreeArray();
            }
        }
        $child = $this->prop('child');
        $child = $child ? $child : $this->prop('children');
        $child = $child ? $child : $this->prop('home'); // MaterialApp??
        // above might be a constant... - technically we could work out the type of that..
        if ($child && !in_array(get_class($child), array( 'eProperty', 'Prop')))  {
            $child = false;
        }
        $childtypes = 0;
        $childtype = '';
        
        
        // to complicated to check if these are widget children ... some are wrappers around
        
        if ($child ) {
            $childtypes = $child->isA('dart:core.List') ? 2 : 1;
            $childtype = count($child->types) ? array_pop($child->types) : $child->type;
            
        }  
        
        return array(
            'name' => $this->name,
            'is_class' => true,
            'cn' => $cn,
            'extends' => $this->extends,
            'is_abstract' => $this->isAbstract,
            'childtypes' => $childtypes,
            'childtype' => $childtype,
            'implementors' => $this->realImplementors, // this is not really complete...
        );
    }
    function isA($name)
    {
        return in_array($name,$this->extends);
    }
    function prop($name)
    {
        foreach($this->props as $p) {
            if ($p->name == $name) {
                return $p;
            }
        }
        return false;
    }
    
    
}
class eMixin extends eClass
{
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}
class eConstant extends Obj
{
    var $type = '';
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
    
}
class eEnum extends eClass // enums look alot like classes..
{
    var $type = '';
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}

class eProperty extends Obj
{
     var $name = '';
    var $type = '?';
    var $desc = '';
    var $memberOf = '';
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
    }
}

class  Prop extends Obj {
    var $name = '';
    var $type = '';
    var $types = array(); // generics...
    var $desc = '';
    var $memberOf = '';
    var $isConstant = false;
    function parseHTML()
    {   
        $dom = Obj::parseHTML();
        // work out the type..
        $rt = $this->getElementsByClassName($dom, 'returntype');
        $this->parseType($rt->item(0));
    }
    function isA($name)
    {
        if (empty($this->types)) {
            return $name == $this->type;
        }
        
        if (in_array($name,$this->types)) {
            return true;
        }
        foreach($this->types as $ty) {
            if (!isset(eClass::$all[$ty])) {
                print_R($this);
                die("could not find type $ty\n");
            }
            if (in_array($name, eClass::$all[$ty]->extends)) {
                return true;
            }
        }
        return false;
    }
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