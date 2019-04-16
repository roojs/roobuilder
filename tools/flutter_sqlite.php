<?php
/*
 * files parsed from
 * https://master-api.flutter.dev/offline/flutter.xml
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
         $this->pdo->exec("
              CREATE TABLE IF NOT EXISTS node (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,

                    href VARCHAR (255) NOT NULL DEFAULT '',
                    name VARCHAR (255) NOT NULL DEFAULT '',
                    type VARCHAR (16) NOT NULL DEFAULT '',
                    overriddenDepth INTEGER NOT NULL DEFAULT '',
                    qualifiedName VARCHAR (255) NOT NULL DEFAULT '',
                    enclosedBy_name VARCHAR (255) NOT NULL DEFAULT '',
                    enclosedBy_type VARCHAR (16) NOT NULL DEFAULT '',
                    -- derived data / html extracted...
                    
                    memberOf VARCHAR (255) NOT NULL DEFAULT '',
                    is_constructor INTEGER NOT NULL DEFAULT 0,
                    is_static INTEGER NOT NULL DEFAULT 0,
                   
                    example TEXT,
                    desc TEXT,
                    
                    is_fake_namespace  INTEGER NOT NULL DEFAULT 0,
                    is_mixin  INTEGER NOT NULL DEFAULT 0,
                    is_enum  INTEGER NOT NULL DEFAULT 0,
                    is_typedef  INTEGER NOT NULL DEFAULT 0,
                    is_constant  INTEGER NOT NULL DEFAULT 0,
                    is_abstract  INTEGER NOT NULL DEFAULT 0,
                    parent_id  INTEGER NOT NULL DEFAULT 0,
                    
                    extends VARCHAR(255)  NOT NULL DEFAULT ''
                );
                    
        ");
         try {
            $this->pdo->exec("ALTER TABLE node ADD COLUMN         is_deprecated INTEGER NOT NULL DEFAULT 0");
         } catch(PDOException $e) {
            // skip;
         }
        
    }
    function get($k,$v)
    {
        print_R(array($k,$v));
        $s = $this->pdo->prepare("SELECT * FROM node where $k=?");
        $s->execute(array($v));
        $r = $s->fetchAll(PDO::FETCH_ASSOC);
         
        if (count($r) != 1) {
            print_R(array($k,$v,$r));
            exit;
        }
        return $r[0];
    }
    function lookup($k,$v)
    {
        print_R(array($k,$v));
        $s = $this->pdo->prepare("SELECT id FROM node where $k=?");
        $s->execute(array($v));
        $r = $s->fetchAll(PDO::FETCH_ASSOC);
        print_R($r);
        if (count($r) > 1) {
            print_R(array($k,$v,$r));
            exit;
        }
        return $r ? $r[0]['id'] : 0;
    }
    function update($id, $o)
    {
        if (empty($o)) {
            return;
        }
        echo "UPDATE";print_r($o);
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
            var_dump($s);
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
        unlink(TDIR.'docs.db');
        $js = json_decode(file_get_contents(FDIR.'index.json'));
        foreach($js as $o) {
            $sq->fromIndex($o);
        }
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
            
             $extends[] = $ex['qualifiedName'];
            
        }
        $ar['extends'] = implode(',', $extends);
        $this->update($id, $ar);
        //print_r(array($extends, $id));exit;
        
    }
    
    function parse($type)
    {
        $s = $this->pdo->prepare("SELECT * FROM node  WHERE type = ?");
        $s->execute(array($type));
        $res = $s->fetchAll(PDO::FETCH_ASSOC);
        foreach($res as $r) {
            $m  = "parse{$type}";
            $this->$m($r);
        }
        
    }
    function parseClass($o)
    {
        $d = $this->readDom($o['href']);
        $this->readDesc($d,$o['id']);
        $this->readClassData($d,$o['id']);
        
    }
    
    
}


define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');
define( 'TDIR', '/home/alan/gitlive/flutter-docs-json/');


$sq = new fsql();
$sq->parseIndex();
$sq->parse('class');
