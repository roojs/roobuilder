<?php


class fsql {
    var $pdo;
    function __construct()
    {
        $this->pdo = new PDO("sqlite:". TDIR . "doc.db");
        $this->create();
    }
    function create()
    {
         $this->pdo->exec("
              CREATE TABLE IF NOT EXISTS node (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,

                    href VARCHAR (255) NOT NULL,
                    name VARCHAR (255) NOT NULL,
                    type VARCHAR (16) NOT NULL,
                    overriddenDepth INTEGER NOT NULL,
                    qualifiedName VARCHAR (255) NOT NULL,
                    enclosedBy_name VARCHAR (255) NOT NULL,
                    enclosedBy_type VARCHAR (16) NOT NULL,
                    -- derived data / html extracted...
                    
                    memberOf VARCHAR (255) NOT NULL,
                    is_constructor INTEGER NOT NULL,
                    is_static INTEGER NOT NULL,
                    is_depricated INTEGER NOT NULL,
                    example TEXT,
                    desc TEXT,
                    
                    is_fake_namespace  INTEGER NOT NULL,
                    is_mixin  INTEGER NOT NULL,
                    is_enum  INTEGER NOT NULL,
                    is_typedef  INTEGER NOT NULL,
                    is_constant  INTEGER NOT NULL,
                    is_abstract  INTEGER NOT NULL,
                    parent_id  INTEGER NOT NULL,
                    
                    extends VARCHAR(255)  NOT NULL
                );
                    
        ");
        
        
    }
    
    function lookup($k,$v)
    {
        $s = $this->pdo->prepare("SELECT id FROM node where $k=?");
        $s->execute(array($v));
        $r = $s->fetchAll();
        return $r ? $r[0]['id'] : 0;
    }
    
    
    
    
    function fromIndex($o)
    {
        $id = $this->lookup('href', $o->href);
        $this->update($id, $o);
        
    }
    
    
    
    
}


define( 'FDIR', '/home/alan/Downloads/flutterdocs/flutter/');
define( 'TDIR', '/home/alan/gitlive/flutter-docs-json/');

$js = json_decode(file_get_contents(FDIR.'index.json'));
$js = json_decode(file_get_contents(FDIR.'index.json'));
$sq = new fsql();
foreach($js as $o) {
    $sq->fromIndex($o);
}
    