<?php
/*
 * files parsed from
 * https://master-api.flutter.dev/offline/flutter.xml
 
 FIXMES
 -- contructor with generic eg. const AlwaysStoppedAnimation<T>(
 -- classes - we need to parse the right hand column to determine which properties/ methods  are static..
 -- enums have methods !! 
 -- types on topLevelconstants are broken (might be able to extract it from the implementation.)
 -- parse packages on left, and create fake libraries for them...
 */

class fsql {
    var $pdo;
    function __construct()
    {
        $this->opendb();
        $this->create();
    }
    function opendb() {
        $this->pdo = new PDO("sqlite:". TDIR . "doc.db");
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
      
    }
    function create()
    {
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_WARNING);

        $this->pdo->exec("
              CREATE TABLE IF NOT EXISTS node (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,

                    href VARCHAR (255) NOT NULL DEFAULT '',
                    name VARCHAR (255) NOT NULL DEFAULT '',
                    type VARCHAR (32) NOT NULL DEFAULT '',
                    overriddenDepth INTEGER NOT NULL DEFAULT '',
                    qualifiedName VARCHAR (255) NOT NULL DEFAULT '',
                    enclosedBy_name VARCHAR (255) NOT NULL DEFAULT '',
                    enclosedBy_type VARCHAR (16) NOT NULL DEFAULT '',
                    -- derived data / html extracted...
                    
                    memberOf            VARCHAR (255) NOT NULL DEFAULT '',
                    is_constructor      INTEGER NOT NULL DEFAULT 0,
                    is_static           INTEGER NOT NULL DEFAULT 0,
                   
                    example TEXT,
                    desc TEXT,
                    
                    is_fake_namespace  INTEGER NOT NULL DEFAULT 0,
                    is_mixin            INTEGER NOT NULL DEFAULT 0,
                    is_enum             INTEGER NOT NULL DEFAULT 0,
                    is_typedef          INTEGER NOT NULL DEFAULT 0,
                    is_constant         INTEGER NOT NULL DEFAULT 0,
                    is_abstract         INTEGER NOT NULL DEFAULT 0,
                    parent_id           INTEGER NOT NULL DEFAULT 0,
                    
                    extends VARCHAR(255)  NOT NULL DEFAULT ''
                    
                );
                    
        ");
         
        $this->pdo->exec("ALTER TABLE node ADD COLUMN         is_deprecated INTEGER NOT NULL DEFAULT 0");
        // deals with param type or return type.
        $this->pdo->exec("ALTER TABLE node ADD COLUMN         value_type VARCHAR (255) NOT NULL DEFAULT ''");
        // for params
        $this->pdo->exec("ALTER TABLE node ADD COLUMN         sequence_no INTEGER NOT NULL DEFAULT 0");
         
        $this->pdo->exec("create index lookup on node(name,qualifiedName,parent_id,type)");
         
        $this->pdo->exec("
            CREATE TABLE IF NOT EXISTS extends (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                class_id INTEGER NOT NULL DEFAULT 0,
                extends_id INTEGER NOT NULL DEFAULT 0
            );
        ");
         
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        
        
        
    }
    function fixParents()
    {
        echo "Grouping properties/methods with parents\n";
        $this->pdo->exec("
            UPDATE
                node as cn 
              set
                parent_id = coalesce((
                  SELECT 
                    id
                  FROM
                    node as pn 
                  where 
                          pn.qualifiedName = substr(cn.qualifiedName, 0, length(cn.qualifiedName) - length(cn.name)) 
                    AND
                    pn.type = 'class'
                  ),0) where
                  enclosedBy_type ='class'
                  and parent_id = 0
        ");
    }
    
    function get($k,$v)
    {
        //print_R(array($k,$v));
        $s = $this->pdo->prepare("SELECT * FROM node where $k=?");
        $s->execute(array($v));
        $r = $s->fetchAll(PDO::FETCH_ASSOC);
         
        if (count($r) != 1) {
            print_R(array($k,$v,$r));
            throw new Exception("not 1 record when searching");
        }
        return $r[0];
    }
    function lookup($k,$v)
    {
        //print_R(array($k,$v));
        $s = $this->pdo->prepare("SELECT id FROM node where $k=?");
        $s->execute(array($v));
        $r = $s->fetchAll(PDO::FETCH_ASSOC);
        //print_R($r);
        if (count($r) > 1) {
            print_R(array($k,$v,$r));
            die("more than one record when calling lookup");
        }
        return $r ? $r[0]['id'] : 0;
    }
    
    function addExtends($class_id , $extends_id)
    {
        $s = $this->pdo->prepare("SELECT id FROM extends where class_id=? AND extends_id=?");
        $s->execute(array($class_id , $extends_id));
        if ($s->fetchAll(PDO::FETCH_ASSOC)) {
            return;
        }
        $s = $this->pdo->prepare("INSERT INTO extends (class_id, extends_id) VALUES (?,?)");
        $s->execute(array($class_id , $extends_id));
        
        
    }
    
    function update($id, $o)
    {
        if (empty($o)) {
            return;
        }
        //echo "UPDATE";print_r($o);
        foreach((array) $o as $k=>$v) {
            if (is_a($v,'stdClass')) {
                foreach((array)$v as $ik  => $iv) {
                    $kk[] = $k . '_' . $ik;
                    $vv[] = '?';
                    $vvv[] = $iv;
                    $kv[]="{$k}_{$ik}=?";
                }
                continue;
            }
            $kk[] = $k;
            $vv[] = '?';
            $vvv[] = $v;
            $kv[]="{$k}=?";
        }
        if (!$id) {
            $s = $this->pdo->prepare("INSERT INTO node (".
                implode(',',$kk) . ") VALUES (".
                implode(',',$vv) . ")");
          //  var_dump($s);
            $s->execute($vvv);
            return;
        }
        $s = $this->pdo->prepare("UPDATE node SET ".
                implode(',',$kv) . " WHERE id = $id");
        $s->execute($vvv);
    }
    
    
    
    
    function fromIndex($o)
    {
        $id = $this->lookup('href', $o->href);
        $this->update($id, $o);
        
    }
    function parseIndex()
    {
        
        $this->pdo = null;
        if (file_exists(TDIR. 'docs.db')) {
            unlink(TDIR.'docs.db');
        }
        $this->opendb();
        $js = json_decode(file_get_contents(FDIR.'index.json'));
        foreach($js as $o) {
            $this->fromIndex($o);
        }
        $sq->fixParents();
    }
    function readDom($url)
    {
        $dom = new DomDocument();
        libxml_use_internal_errors(true);
        echo "Reading : {$url}\n";
        $dom->loadHTMLFile(FDIR . $url);
        libxml_clear_errors();
        $xp = new DomXPath($dom);
        
        return $dom;
    }
    function getElementsByClassName($dom, $class, $node = null)
    {
        $xp = new DomXPath($dom);
        return $xp->query("//*[contains(concat(' ', @class, ' '), ' ".$class." ')]", $node);
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
    function readDesc($dom, $id)
    {
        $array = array();
        $desc = $this->getElementsByClassName($dom, 'desc');
        if ($desc->length) {
            $array['desc'] = $this->innerHTML($desc->item(0));
        }
        $sc = $this->getElementsByClassName($dom, 'source-code');
        if ($sc->length) {
            $array['example'] = $this->innerHTML($sc->item(0));
        }
        $this->update($id, $array);
        
    }
    function readClassData($dom, $id)
    {
        $ar = array();
        $sc = $this->getElementsByClassName($dom,'self-crumb');

        if ($sc->length) {
            // abstracts actually impletment stuff in flutter...
            if (preg_match('/abstract class/', $this->innerHTML($sc->item(0)))) {
                $ar['is_abstract'] = 1;
            }
        }
        $this->update($id, $ar);
        $dl = $dom->getElementsByTagName('dl')->item(0);
        if ($dl->getAttribute('class') != 'dl-horizontal') {
             return;
        }
        if (strpos($this->innerHTML($dl), '@deprecated')) {
            $ar['is_deprecated'] = 1;
            $this->update($id, $ar);
        }
        $dt = $dl->getElementsByTagName('dt');
        if (!$dt->length || $this->innerHTML($dt->item(0)) != 'Inheritance') {
            return;
        }
        $dd = $dl->getElementsByTagName('dd');
        if (!$dd->length) {
            return;
        }
        
        $as = $dd->item(0)->getElementsByTagName('a');
        $extends = array();        
        for($i = $as->length-1;$i > -1; $i--) {

            $ex = $this->get('href', $as->item($i)->getAttribute('href'));
            if (!$ex) {
                die("could not find " . $as->item($i)->getAttribute('href') . " when parsing" . $id);
            }
            if (empty($ex['qualifiedName'])) {
                
                print_r($ex);die("missing qualifiedName");
            }
            $this->addExtends($id, $ex['id']);
            $extends[] = $ex['qualifiedName'];
            
        }
        $ar['extends'] = implode(',', $extends);
        $this->update($id, $ar);
        //print_r(array($extends, $id));exit;
        
    }
    
    function readReturnType($dom, $id)
    {
        
        $sp = $this->getElementsByClassName($dom,'returntype')->item(0);
        $vt = $this->readTypeToString($sp);
        $this->update($id, array('value_type' => $vt));
        
        
    }
    function readSignature($dom, $id)
    {
        // simple type:
        // String
        // complex type
        // List<Widget> ... --- List -> generic type = Widget
        // let's start by just storing the values.
        // in where? -
        /*
         * node
         *    type='param'
         *    href='';
         *    parent_id
         *
         */
        
         $parent = $this->get('id',$id);
        $ar = $this->getElementsByClassName($dom,'parameter');
        for($i =0;$i<$ar->length;$i++) {
            // paramenters are used where methods return callbacks with their own params..
            if ($ar->item($i)->parentNode->getAttribute('class') == 'signature') {
                continue;
            }
            $this->readParam( $id,  $ar->item($i) ,  $parent['qualifiedName'] .'.param');
        }   
        return $dom;
        
    }
    
    function readParam($id, $node, $prefix)
    {
        $ar  = $node->getElementsByTagName('span');
        if (!$ar->length) {
            echo $this->innerHTML($node);
            die("mssing paramter info");
        }
       
        $o = array(
            'type' => 'param',
            'parent_id' => $id,
            'href' => '',
            
        );
        $seq = 1;
        for($i = 0; $i < $ar->length; $i++) {
            
            switch($ar->item($i)->getAttribute('class')) {
                
                case 'parameter-name':
                    $o['name'] = $ar->item($i)->textContent;
                    $o['sequence_no'] = $seq++;
                    $o['qualifiedName' ] = $prefix . '.'. $o['name'] ;
                    break;
                
                case 'type-annotation':
                    
                    $o['value_type'] = $this->readTypeToString($ar->item($i) );
                    break;
                
            }
        }
        if (empty($o['qualifiedName' ])) {
            $out = $this->get('id', $id);
            print_r($out);
            die("missing paramenter name onn this page:" .$out['href']);
            
        }
        
        $id = $this->lookup('qualifiedName',$o['qualifiedName' ] );
        $this->update($id,$o);
        
    }
   
    function readTypeToString($sp)
    {
        if (!$sp) {
            print_R($this);
            die("readTypeToString got invalid value");
            
        }
        $type = '';
        $ar = $sp->getElementsByTagName('a');
        if (!$ar->length) {
            return '<'. $sp->textContent .'>'; // guessing these are generics..
        }
        if ($ar->length == 1) {
            $rt = $this->get('href',$ar->item(0)->getAttribute('href'));
            return  $rt['qualifiedName'];
        } 
        $types = array();
        $t = '';
        for($i =0;$i<$ar->length;$i++) {
            $rt = $this->get('href',$ar->item($i)->getAttribute('href'));
            
            $types[] = $rt['qualifiedName'];
             
            //$t .= ($i == 0) ? $rt['qualifiedName'];: ('<'. $rt['qualifiedName'];);
             
        }
        //for($i =0;$i<$ar->length-1;$i++) {
        //    $t .= '>';
       // }
        return implode(',', $types);
        
         
        
    }
    
    var $blacklist = array(
        'dart-io/HttpOverrides/runZoned.html', // very complex method call - object with callbacks..
        'dart-io/IOOverrides/runZoned.html',// insanly complex method call - object with callbacks..
        'dart-async/StreamTransformer/StreamTransformer.fromBind.html', // complex ctor
    );
    
    function parse($type)
    {
        echo "Parse $type\n";
        $s = $this->pdo->prepare("SELECT * FROM node  WHERE type = ?");
        $s->execute(array($type));
        $res = $s->fetchAll(PDO::FETCH_ASSOC);
        foreach($res as $r) {
            if (in_array($r['href'], $this->blacklist)) {
                continue;
            }
            $m  = "parse".preg_replace('/[^A-Z]/i', '', $type);
            $this->$m($r);
        }
        
    }
    function parseClass($o)
    {
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        $this->readClassData($d,$o['id']);
        
    }
    
    function parseConstructor($o)
    {
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        $this->readSignature($d,$o['id']);
    }
    function parseMethod($o)
    {
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        $this->readReturnType($d,$o['id']);        
        $this->readSignature($d,$o['id']);
    }
    function parseProperty($o)
    {
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        $this->readReturnType($d,$o['id']);        

    }
    function parseEnum($o)
    {
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        //$this->readReturnType($d,$o['id']);
        $ct = $d->getElementById('constants');
        $props = $this->getElementsByClassName($ct->ownerDocument,'properties',$ct)->item(0);
        //echo $this->innerHTML($props);
        for($i = 0; $i< $props->childNodes->length; $i++) {
            $cn  = $props->childNodes->item($i);
            //var_dump($cn->nodeName);
            switch($cn->nodeName) {
                case 'dt': // look for name
                    
                    $name = $cn->getElementsByTagName('span')->item(0)->textContent; //$this->getElementsByClassName($cn->ownerDocument,'name',$cn)->item(0)->textContent;
                    //var_Dump($name);
                    $n = array(
                        'type' => 'enum-value',
                        'parent_id' => $o['id'],
                        'qualifiedName' => $o['qualifiedName'] .'.' . $name,
                        'name' => $name,
                        // enclosed by?? - leave?
                    );
                    
                    break;
                case 'dd': // the description
                    //print_r($n);
                    $n['desc']  =  $this->innerHTML($cn);
                    
                    $id = $this->lookup('qualifiedName', $n['qualifiedName']);
                    if (!strlen(trim($n['name']))) {
                        break;
                    }
                    $this->update($id, $n);
                    //print_r($n);
                    break;
            }
             
        }
        // we ignore methods???
        //exit;
        

    }
    function parseMixin($o)
    {
        // oddly enough mixin's have ctors???
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        // methods and props should be handled ok anyway.. 
        
        //print_R($o);exit;
        
    }
    function parsetypeDef($o)
    {
        // these appear to be function signatures really.
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        // methods and props should be handled ok anyway.. 
        
        //print_R($o);exit;
        
    }
    function parseConstant($o)
    {
        // these appear to be function signatures really.
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        // methods and props should be handled ok anyway.. 
        $this->readReturnType($d,$o['id']);  
      
        
    }
    
    function parseTopLevelConstant($o)
    {
        
       
        // these appear to be function signatures really.
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        // methods and props should be handled ok anyway.. 
        //$this->readReturnType($d,$o['id']);  
      
    }
    function parseTopLevelProperty($o)
    {
        
        //print_r($o);exit;
        // aliases to pre-created classes...
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        // methods and props should be handled ok anyway.. 
        $this->readReturnType($d,$o['id']);  
      
    }
    function parseFunction($o)
    {
        
      //  print_r($o);exit;
        // these appear to be function signatures really.
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        // methods and props should be handled ok anyway.. 
        $this->readReturnType($d,$o['id']);
        $this->readSignature($d,$o['id']);
      
        
    }
    /* ----------------------------- OUTPUT -----------------------------*/
    
    function outImplementorsToArray($id)
    {
        $res = $this->pdo->query("
            SELECT
                    qualifiedName
                FROM
                    node
                where
                    id IN (SELECT distinct(class_id) FROM extends WHERE extends_id = {$id})
                AND
                    is_abstract = 0
                order by
                    qualifiedName ASC
        ");
        return  $res->fetchAll(PDO::FETCH_COLUMN);
    }
    
    function outTree()
    {
        ///make a tree of the classes, and collapse the classes that have same prefix into the prefix.
        echo "Creating Tree.json\n";
        // our tree should only include classes (non-abstract), and namespaces
        $res = $this->pdo->query("
            SELECT
                    id,
                    qualifiedName as name,
                    qualifiedName,
                    type,
                    CASE WHEN type != 'library'  THEN 1 ELSE 0 END AS is_class,
                    is_abstract,
                    extends 
                from
                    node
                where
                    type IN ('class', 'library', 'enum', 'mixin')
                
                order by
                    qualifiedName ASC
        ");
        $all = $res->fetchAll(PDO::FETCH_ASSOC);
        $stack = array();
        $nsmap = array();
        foreach($all as $o) {
            $add = (object) $o;
            $add->cn = array();
            $add->is_class = $add->is_class == 1;
            unset($add->id);
            $add->extends = strlen($add->extends) ? explode(',',$add->extends) : array();
            if ($o['type'] == 'library') {
                 
                $out[] = $add;
                $stack = array($add);
                continue;
            }
            
            $add->implementors  = $this->outImplementorsToArray($o['id']);
            
            // find if the element has a child or children...
            // this is not really where this should go.. but we will add it for the time being.
            
            
            $res = $this->pdo->query("
                SELECT
                        name, value_type
                    FROM
                        node
                    where
                        (
                            parent_id = {$o['id']}
                            OR
                            parent_id IN (SELECT distinct(class_id) FROM extends WHERE extends_id = {$o['id']})
                        )
                    AND
                        type = 'property'
                    AND
                        name IN ('child','children','home', 'body')
                    order by
                        name ASC
                    limit 1
            "); 
            $types = $res->fetch(PDO::FETCH_ASSOC);
            $add->childtype = '';
            $add->childtypes = '0';
            if ($types) {
                $car = explode(',', $types['value_type']);
                $add->childtype = array_pop($car);
                $add->childtypes = (count($car) && $car[0] == 'date:core.List') ? 2 : 1;
            }
            
            
            //echo "looking for " .$o['qualifiedName'];             print_R($stack);
            for($i = count($stack)-1; $i > -1; $i--) {
                $last = $stack[$i];
                //print_r(array( substr($o['qualifiedName'], 0, strlen($last->qualifiedName)), $last->qualifiedName));
                if (substr($add->qualifiedName, 0, strlen($last->qualifiedName)) == $last->qualifiedName) {
                    $last->cn[] = $add;
                    $stack[$i+1] = $add;
                    break;
                }
                 
                
            }
        }
        $libs = array();
        foreach($out as $c) {
            $this->outTreeGroups($c);
            $bits = explode(".", $c->qualifiedName);
            if (count($bits)< 2 || !isset($libs[$bits[0]])) {
                $libs[$c->qualifiedName]  = $c;
                continue;
            }
            $libs[$bits[0]]->cn[] = $c;
        }
        
        $out = array_values($libs);
        echo "WRITE: " .TDIR ."tree.json\n";
        file_put_contents(TDIR .'tree.json', json_encode($out, JSON_PRETTY_PRINT));

        //print_r($out);
        
        
        
    }
    function outTreeGroups($obj)
    {
        $groups= array();
        $libs = array();
        foreach($obj->cn as $c) {
            
            $name = substr($c->qualifiedName, strlen($obj->qualifiedName) +1);
            $bits = preg_split('/(?<=[a-z])(?=[A-Z])|(?=[A-Z][a-z])/',
                                 $name, -1, PREG_SPLIT_NO_EMPTY);
            if (!isset($groups[$bits[0]])) {
                $groups[$bits[0]] = array();
            }
            $groups[$bits[0]][] = $c;
        }
        $obj->cn = $libs;
        foreach($groups as $k => $list) {
            if (count($list) < 2) {
                $obj->cn[] = $list[0];
                continue;
            }
            $obj->cn[] = (object) array(
                'name' => $obj->qualifiedName .'.' . $k,
                'qualifiedName' => $obj->qualifiedName .'.' . $k,
                'cn' => $list,
                'is_class' => 'false',
                'type' => 'group',
            );
        }
        
    }
    
    function typeStringToGeneric($str)
    {
        $bits = explode(',', $str);
        if (count($bits) < 2) {
            return $str;
        }
        $t = '';
        foreach($bits as $i => $add) {
            $t .= ($i == 0) ? $add : ('<'. $add );
             
        }
        for($i =0;$i<count($bits)-1;$i++) {
            $t .= '>';
        }
        return $t;
    }
    
     
    function outClassSymbols()
    {
        echo "Writing Class Symbols\n";
        $res = $this->pdo->query("
            SELECT
                    id,
                    COALESCE(desc, '') as desc,
                    type as dtype,
                    COALESCE(example, '') as example,
                    href,
                    is_abstract as isAbstract,
                    false as isConstant,
                    is_deprecated as isDeprecated,
                     
                    enclosedBy_name as memberOf,
                    qualifiedName as name,
                    name as shortname,
                    extends
                from
                    node
                where
                    type IN ('class', 'mixin', 'enum')
                
                order by
                    qualifiedName ASC
        ");
        $all = $res->fetchAll(PDO::FETCH_ASSOC);
        $ns = array();
        foreach($all as $clsar) {
            $cls = (object) $clsar;
            unset($cls->id);
            
            if (!isset($ns[$cls->memberOf])) {
                $ns[$cls->memberOf] = (object) array(
                    'class' => array(),
                    'mixin' => array(),
                    //'constants' => array(), // within a class.. - we could treat as static properties..
                    'enum' => array(),  // like a class...
                    'typedef' => array(), // need to query these seperatly... -- look very different to classes..
                    // functions (within a library... )
                    // top level constant? (within a library - without a class)
                    // top level proeprty? (predefined instances of clases) - within a library
                );
            }
            
            $cls->isConstant = $cls->isConstant == 1;

            $cls->isAbstract = $cls->isAbstract == 1;
            $cls->isDeprecated = $cls->isDeprecated == 1;
            $cls->is_enum = $cls->dtype == 'enum';
            $cls->is_mixin = $cls->dtype == 'mixin';
            //$cls->is_typedef = $cls->is_typedef = 1;
            $cls->extends = strlen($cls->extends) ? explode(',',$cls->extends) : array();
            $cls->realImplementors  = $this->outImplementorsToArray($clsar['id']);
            $cls->events = $this->outEventSymbols($clsar); // event's are properties that are typedefs..
            $cls->methods = $this->outMethodSymbols($clsar);
            $cls->props = $this->outPropertySymbols($clsar);
            
            echo "OUT:".TDIR .'symbols/'.$cls->name. '.json' ."\n";
            file_put_contents(TDIR .'symbols/'.$cls->name. '.json', json_encode($cls,JSON_PRETTY_PRINT));
            
            
            $ns[$cls->memberOf]->{$cls->dtype}[] = $cls;
            
        }
        foreach($ns as $nm => $cls) {
            echo "OUT:".TDIR .'ns/'.$nm. '.json' ."\n";
            file_put_contents(TDIR .'ns/'.$nm. '.json', json_encode($cls,JSON_PRETTY_PRINT));
        }
        
        
        
    }
    
    function outEventSymbols($c)
    {
        $res = $this->pdo->query("
            SELECT
                    id,
                    COALESCE(desc, '') as desc,
                    COALESCE(example, '') as example,
                    href,
                    is_deprecated as isDeprecated,
                    value_type as type,
                    name as name
                from 
                        node 
                where 
                        parent_id = {$c['id']}
                        AND
                        type IN ('property')
                        AND
                        'typedef' = (SELECT type from node as sc where sc.qualifiedName = (CASE 
                        WHEN instr(node.value_type,',') > 0 
                        THEN substr(node.value_type, 0, instr(node.value_type,',')) 
                        ELSE node.value_type  
                        END) limit 1) ;
                    
                
                order by
                    qualifiedName ASC
        ");
        $all = $res->fetchAll(PDO::FETCH_ASSOC);
        $events = array();
        foreach($all as $evar) {
            $ev = (object) $evar;
            unset($ev->id);
            $ev->isDeprecated = $ev->isDeprecated == 1;
            $ev->memberOf = $c['name'];
            $ev->params = array(); // FIXME
            $ev->type = $this->typeStringToGeneric($ev->type);
            $events[] = $ev;
            
        }
        return $events;
        
    }
    
    function outPropertySymbols($c)
    {
        $res = $this->pdo->query("
            SELECT
                    id,
                    COALESCE(desc, '') as desc,
                    COALESCE(example, '') as example,
                    href,
                    name as name,
                    is_deprecated as isDeprecated,
                    value_type as type,
                    type as dtype
                    
                from 
                        node 
                where 
                        parent_id = {$c['id']}
                        AND
                        (
                            (
                                type IN ('property')
                                AND
                                'typedef' != (SELECT type from node as sc where sc.qualifiedName = (CASE 
                                WHEN instr(node.value_type,',') > 0 
                                THEN substr(node.value_type, 0, instr(node.value_type,',')) 
                                ELSE node.value_type  
                                END) limit 1)
                            ) OR (
                                type IN ('constant', 'enum-value')
                            )
                            
                        );
                    
                
                order by
                    qualifiedName ASC
        ");
        $all = $res->fetchAll(PDO::FETCH_ASSOC);
        $events = array();
        foreach($all as $evar) {
            $ev = (object) $evar;
            unset($ev->id);
            $ev->isStatic = in_array($ev->dtype , array( 'constant', 'enum-value')); // since we do not know what static properties are...
            $ev->isConstant = in_array($ev->dtype , array( 'constant', 'enum-value'));
            $ev->memberOf = $c['name'];
            $ev->isDeprecated = $ev->isDeprecated == 1;
            $ev->params = array(); // FIXME
            $ev->type = $this->typeStringToGeneric($ev->type);
            $events[] = $ev;
            
        }
        return $events;
        
    }
    function outMethodSymbols($c)
    {
        
          $res = $this->pdo->query("
            SELECT
                    id,
                    COALESCE(desc, '') as desc,
                    COALESCE(example, '') as example,
                    href,
                    is_deprecated as isDeprecated,
                    value_type as type,
                    name as name,
                    type as dtype
                from 
                        node 
                where 
                        parent_id = {$c['id']}
                        AND
                        type IN ('method','constructor')
                         
                    
                
                order by
                    qualifiedName ASC
        ");
        $all = $res->fetchAll(PDO::FETCH_ASSOC);
        $events = array();
        foreach($all as $evar) {
            $ev = (object) $evar;
            unset($ev->id);
            $ev->isConstructor = $ev->dtype == 'constructor';
             
            $ev->static = false;
            $ev->memberOf = $c['name'];
            $ev->isDeprecated = $ev->isDeprecated == 1;            
            $ev->params = $this->outParamSymbols($evar);
            $ev->type = $this->typeStringToGeneric($ev->type);
            $events[] = $ev;
            
        }
        return $events;
        
    }
    function outParamSymbols($c)
    {
        
          $res = $this->pdo->query("
            SELECT
                    id,
                    name as name,
                    COALESCE(desc, '') as desc,
                    COALESCE(example, '') as example,
                    href,
                    is_deprecated as isDeprecated,
                    false as isOptional,
                    value_type as type
                from 
                        node 
                where 
                        parent_id = {$c['id']}
                        AND
                        type IN ('param')
                         
                    
                
                order by
                    qualifiedName ASC
        ");
        $all = $res->fetchAll(PDO::FETCH_ASSOC);
        $events = array();
        foreach($all as $evar) {
            $ev = (object) $evar;
            unset($ev->id);
            $ev->isDeprecated = $ev->isDeprecated == 1;
            $ev->isOptional = $c['dtype'] == 'constructor';
            $ev->type = $this->typeStringToGeneric($ev->type);
            $events[] = $ev;
            
        }
        return $events;
        
    }
    
    
}


define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');
define( 'TDIR', '/home/alan/gitlive/flutter-docs-json/'); 
 
$sq = new fsql();
print_r($_SERVER['argv']);
if (!empty($_SERVER['argv'][1]) && $_SERVER['argv'][1] == 'index') {
    echo "rebuilding Index" ;$sq->parseIndex();exit;
}
//$sq->parse('library'); // what does this achieve?
/*
$sq->parse('class');
$sq->parse('constructor');
$sq->parse('method');
$sq->parse('property');
$sq->parse('enum');
$sq->parse('mixin');
$sq->parse('typedef');
$sq->parse('constant');
$sq->parse('top-level constant');
$sq->parse('function');
$sq->parse('top-level property');


*/
//
//
//$sq->outTree();
$sq->outClassSymbols();
