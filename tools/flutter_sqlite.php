<?php


class fsql {
    var $pdo;
    function __construct()
    {
        $this->pdo = new PDO("sqlite:". JDIR . "doc.db");
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
                    
        ")
        
        
    }
    
    
}
