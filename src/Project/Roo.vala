 

 

public class Project.Roo : Project {

	public Palete.RooDatabase roo_database;

	public string runhtml = "";
	public string base_template = "";
	public string rootURL = "";
	public string html_gen = "";
	public string DBTYPE = "";
	public string DBNAME = "";
	public string DBUSERNAME = "";  // should be stored in settings somehwere - not in roo file!
	public string DBPASSWORD = "";	 
    public Roo(string path) {

		
        base(path);
  		this.palete = new Palete.Roo(this);
        this.xtype = "Roo";
        // various loader methods..
        //this.id = "project-roo-%d".printf(rid++);
		this.initDatabase();
        
    }
	public override void   initDatabase()
	{
		this.roo_database = new Palete.RooDatabase.from_project(this);   
	}
	public override void loadJson(Json.Object obj) 
	{
		// might not exist?

		if (obj.has_member("runhtml")) {
				this.runhtml  = obj.get_string_member("runhtml"); 
		}
		// might not exist?
		if (obj.has_member("base_template")) {
				this.base_template  = obj.get_string_member("base_template"); 
		}
		// might not exist?
		if (obj.has_member("rootURL")) {
				this.rootURL  = obj.get_string_member("rootURL"); 
		}
		
		if (obj.has_member("html_gen")) {
				this.html_gen  = obj.get_string_member("html_gen"); 
		}
		if (obj.has_member("DBTYPE")) {
				this.DBTYPE  = obj.get_string_member("DBTYPE"); 
		}
		
		if (obj.has_member("DBNAME")) {
				this.DBNAME  = obj.get_string_member("DBNAME"); 
		}
		//if (obj.has_member("DBUSERNAME")) {
		//		this.DBUSERNAME  = obj.get_string_member("DBUSERNAME"); 
		//}
		//if (obj.has_member("DBPASSWORD")) {
		//		this.DBPASSWORD  = obj.get_string_member("DBPASSWORD"); 
		//}
		
	}
	public override void saveJson(Json.Object obj)
	{
		//obj.set_string_member("fn", this.fn);

		obj.set_string_member("runhtml", this.runhtml);
		obj.set_string_member("rootURL", this.rootURL);
		obj.set_string_member("base_template", this.base_template);
		obj.set_string_member("rootURL", this.rootURL);
		obj.set_string_member("html_gen", this.html_gen);
		obj.set_string_member("DBTYPE", this.DBTYPE);
		obj.set_string_member("DBNAME", this.DBNAME);
		//obj.set_string_member("DBUSERNAME", this.DBUSERNAME);			
		//obj.set_string_member("DBPASSWORD", this.DBPASSWORD);
	}
	
	public override void initialize() {
		// ?? what kind of files can we set up a project ?
	}
	public override void onSave()
	{
		 // nope
	}

}
 
 