<?php

// in flutter - an event is actually a property..?

// we have 2 types of data - the overall summary, and the 'detail one we use for docs..
//
/*
 
 TODO:
  Generics CompoundAnimation<T> ... or 
      children → List<Widget>  << fixed..
    material/PopupMenuEntry-class.html     
    http://localhost/roojs1/docs/?/flutter/#material.PopupMenuDivider
      
      
  Constants on Libraries.. /? classes?
  
  Abstracts - no need to show them in menu?
   
  extends link:
  source link?
  generic links...
  
  
  config --- constructor links...
  
  
 */

require_once 'flutter_nodes.php'; // the classes..

define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');
define( 'TDIR', '/home/alan/gitlive/flutter-docs-json/');

 /*
$c = new eClass(array(
    'name' => 'dart:core.List',
    'href' => 'dart-core/List-class.html',
    'memberOf' => 'dart:core',
    'dtype' => 'class' 
));

// let's do some testing...
$c = new eClass(array(
    'name' => 'dart:core.Object',
    'href' => 'dart-core/Object-class.html',
    'memberOf' => 'dart:core',
    'dtype' => 'class' 
));

$c = new eClass(array(
    'name' => 'foundation.Diagnosticable',
    'href' => 'foundation/Diagnosticable-class.html',
    'memberOf' => 'foundation',
    'dtype' => 'class' 
));

$c = new eClass(array(
    'name' => 'foundation.DiagnosticableTree',
    'href' => 'foundation/DiagnosticableTree-class.html',
    'memberOf' => 'foundation',
    'dtype' => 'class' 
));



$c = new eClass(array(
    'name' => 'widgets.Widget',
    'href' => 'widgets/Widget-class.html',
    'memberOf' => 'widgets',
    'dtype' => 'class'
));
$c = new eClass(array(
    'name' => 'widgets.StatelessWidget',
    'href' => 'widgets/StatelessWidget-class.html',
    'memberOf' => 'widgets',
    'dtype' => 'class'
));

$c = new eClass(array(
    'name' => 'widgets.StatelessWidget',
    'href' => 'widgets/StatelessWidget-class.html',
    'memberOf' => 'widgets',
    'dtype' => 'class'
));

$c = new eClass(array(
    'name' => 'material.AboutDialog',
    'href' => 'material/AboutDialog-class.html',
    'memberOf' => 'material',
    'dtype' => 'class'
));
  $add =  new Prop(array(
                'name' => 'children',
                'href' => 'material/AboutDialog/children.html',
                'memberOf' => 'material.AboutDialog'
            ));
            
            $c->props[] = $add;

$c->readDocs();
print_r($c);
exit;
 
*/


$js = json_decode(file_get_contents(FDIR.'index.json'));

foreach($js as $o) {
   
    
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
                'memberOf' => $cls,
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
                'memberOf' => $cls
            ));
            
            eClass::$all[$cls]->props[] = $add;
        
            break;  
        default:
            print_R($o);
            die("invalid type {$o->type}");
    }
    
    
    
}




$summary = array();
if (!file_exists(TDIR .'symbols')) {
    mkdir(FDIR .'symbols', 0755, true);
}
if (!file_exists(TDIR .'ns')) {
    mkdir(FDIR .'ns', 0755, true);
}



foreach(eClass::$all as $c) {
    
    if (!method_exists($c, 'readDocs')) {
        echo "missing readDocs";
        print_R($c);exit;
    }
    $c->readDocs();
    // constant's and other mixins.. 
}
// at this point we need to dump the whole thing.





foreach(eClass::$all as $c) {
    
    if (!method_exists($c, 'readDocs')) {
        echo "missing readDocs";
        print_R($c);exit;
    }
    if (is_a($c, 'eClass') ||is_a($c, 'eMixin') ) {
        $c->expandImplementors();
    }
    // constant's and other mixins.. 
}

// output the files..
foreach(eClass::$all as $c) {
    //$summary[$c->name] = $c->toSummaryArray();
    if (is_a($c, 'eClass') ||is_a($c, 'eMixin') ) {
        $c->realImplementors();
        file_put_contents(TDIR .'symbols/'.$c->name. '.json', json_encode($c,JSON_PRETTY_PRINT));
    }
    // constant's and other mixins.. 
}
foreach(Ns::$tree as $c) {
    //$summary[$c->name] = $c->toSummaryArray();
    file_put_contents(TDIR .'ns/'.$c->name. '.json', json_encode($c,JSON_PRETTY_PRINT));
    
    // constant's and other mixins.. 
}
$tree = array();
foreach(Ns::$tree as $e) {
    $e->fakeTree();
    $tree[] = $e->toTreeArray();
}
file_put_contents(TDIR .'tree.json', json_encode($tree, JSON_PRETTY_PRINT));
//file_put_contents(FDIR .'json/index.json', json_encode($summary, JSON_PRETTY_PRINT)); // this is for builder.. later..

//print_r(eClass::$all);