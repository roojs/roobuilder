//<script type="text/javscript">

/**
	@namespace
*/
// test
// valac gitlive/app.Builder.js/JsRender/Lang.vala --pkg gee-1.0 -o /tmp/Lang ;/tmp/Lang

/*
void main () {
     new JsRender.Lang_Class();
    print(JsRender.Lang.keyword("delete") + "\n");
}
*/
 

namespace JsRender { 
    public Lang_Class Lang = null;
    
    public class Lang_Class : Object {
        
        GLib.List<string> coreObjects;
        Gee.HashMap<string,string> whitespaceNames;
        Gee.HashMap<string,string> newlineNames;
        Gee.HashMap<string,string> keywordNames;
        Gee.HashMap<string,string> puncNames;
        Gee.HashMap<string,string> matchingNames;
        public Gee.ArrayList<string> match_strings;
        
        public Lang_Class ()
        {
            if (Lang != null) {
                //print("lang not null\n");
                return;
            }
            //print("init\n");
            this.init();
            //print("init Lang");
            Lang = this;
            
        }
        
        
        public bool isBuiltin(string  name) {
            return (this.coreObjects.index(name) > -1);
        }
        
        public string whitespace (string ch) {
            return this.whitespaceNames.get(ch);
        }
        public string  newline (string ch) {
            return this.newlineNames.get(ch);
        }
        public string keyword(string word) {
            return this.keywordNames.get("="+word);
        }
        
        public string matching(string name) {
            return this.matchingNames.get(name);
        }
        
        public bool isKeyword(string word) {
            return this.keywordNames.get("=" + word) != null;
            
        }
        public string punc (string ch) {
            return this.puncNames[ch];
        }
        
        public bool isNumber (string str) {
            return Regex.match_simple("^(\\.[0-9]|[0-9]+\\.|[0-9])[0-9]*([eE][+-][0-9]+)?$",str);
        }
    
        public bool  isHexDec (string str) {
            return Regex.match_simple("^0x[0-9A-F]+$",str);
        }
    
        public bool isWordChar (string str) {
            return Regex.match_simple("^[a-zA-Z0-9$_.]+$", str);
        }
    
        public bool isSpace (string str) {
            return this.whitespaceNames.get(str) != null;
        }
    
        public bool isNewline (string str) {
            return this.newlineNames.get(str) != null;
        }
 	    public bool isBoolean (string str) {
			var ss = str.down();
            return ss == "false" || ss == "true";
        }
        
        
        
        
        void init() {
            
            this.coreObjects = new GLib.List<string>();
            
            this.whitespaceNames = new Gee.HashMap<string,string>();
            this.newlineNames = new Gee.HashMap<string,string>();
            this.keywordNames = new Gee.HashMap<string,string>();
            this.puncNames = new Gee.HashMap<string,string>();
            this.matchingNames = new Gee.HashMap<string,string>();
            this.match_strings = new Gee.ArrayList<string>();
            
            
            string[] co = { "_global_", "Array", "Boolean", "Date", "Error", 
                "Function", "Math", "Number", "Object", "RegExp", "String" };
            for(var i =0; i< co.length;i++ ) {
                this.coreObjects.append(co[i]);
                this.match_strings.add(co[i]);
            }
            string[] ws =  {
                " :SPACE",
                "\f:FORMFEED",
                "\t:TAB" //,
              //  "\u0009:UNICODE_TAB",
              //  "\u000A:UNICODE_NBR",
              //  "\u0008:VERTICAL_TAB"
            };
            for(var i =0; i< ws.length;i++ ) {
                var x = ws[i].split(":");
                this.whitespaceNames.set(x[0],x[1]);
            }
            
            ws = {
                "\n:NEWLINE",
                "\r:RETURN" //,
    //            "\u000A:UNICODE_LF",
      //          "\u000D:UNICODE_CR",
        //        "\u2029:UNICODE_PS",
          //      "\u2028:UNICODE_LS"
            };
            for(var i =0; i< ws.length;i++ ) {
                var x = ws[i].split(":");
                this.newlineNames.set(x[0],x[1]);
            }
            ws = {
                "=break:BREAK",
                "=case:CASE",
                "=catch:CATCH",
                "=const:VAR",
                "=continue:CONTINUE",
                "=default:DEFAULT",
                "=delete:DELETE",
                "=do:DO",
                "=else:ELSE",
                "=false:FALSE",
                "=finally:FINALLY",
                "=for:FOR",
                "=function:FUNCTION",
                "=if:IF",
                "=in:IN",
                "=instanceof:INSTANCEOF",
                "=new:NEW",
                "=null:NULL",
                "=return:RETURN",
                "=switch:SWITCH",
                "=this:THIS",
                "=throw:THROW",
                "=true:TRUE",
                "=try:TRY",
                "=typeof:TYPEOF",
                "=void:VOID",
                "=while:WHILE",
                "=with:WITH",
                "=var:VAR"
             };
            for(var i =0; i< ws.length;i++ ) {
                var x = ws[i].split(":");
                this.keywordNames.set(x[0],x[1]);
                this.match_strings.add(x[0].substring(1));
            }
        
      
            ws={
                "; SEMICOLON",
                ", COMMA",
                "? HOOK",
                ": COLON",
                "|| OR", 
                "&& AND",
                "| BITWISE_OR",
                "^ BITWISE_XOR",
                "& BITWISE_AND",
                "=== STRICT_EQ", 
                "== EQ",
                "= ASSIGN",
                "!== STRICT_NE",
                "!= NE",
                "<< LSH",
                "<= LE", 
                "< LT",
                ">>> URSH",
                ">> RSH",
                ">= GE",
                "> GT", 
                "++ INCREMENT",
                "-- DECREMENT",
                "+ PLUS",
                "- MINUS",
                "* MUL",
                "/ DIV", 
                "% MOD",
                "! NOT",
                "~ BITWISE_NOT",
                ". DOT",
                "[ LEFT_BRACE",
                "] RIGHT_BRACE",
                "{ LEFT_CURLY",
                "} RIGHT_CURLY",
                "( LEFT_PAREN",
                ") RIGHT_PAREN"
            };
            for(var i =0; i< ws.length;i++ ) {
                var x = ws[i].split(" ");
                this.puncNames.set(x[0],x[1]);
            }
        
           ws = {
               "LEFT_PAREN:RIGHT_PAREN",
               "RIGHT_PAREN:LEFT_PAREN",
               "LEFT_CURLY:RIGHT_CURLY",
               "RIGHT_CURLY:LEFT_CURLY",
               "LEFT_BRACE:RIGHT_BRACE",
               "RIGHT_BRACE:LEFT_BRACE"
           };
           for(var i =0; i< ws.length;i++ ) {
               var x = ws[i].split(":");
               this.matchingNames.set(x[0],x[1]);
           }
           
           
           
           
        }
        
        
    }
}