 

static int rid = 1;

public class Project.Roo : Project {

	public Palete.RooDatabase roo_database;

    public Roo(string path) {

		
        base(path);
  		this.palete = new Palete.Roo(this);
        this.xtype = "Roo";
        // various loader methods..
        this.id = "project-roo-%d".printf(rid++);
		this.initDatabase();
        
    }
     public override void   initDatabase()
    {
         this.roo_database = new Palete.RooDatabase.from_project(this);   
    }
	public override void loadJson(Json.Object obj) throws GLib.Error 
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
		
	}
	public override string saveJson(Json.Object obj
	{
			obj.set_string_member("fn", this.fn);

			obj.set_string_member("runhtml", this.runhtml);
			obj.set_string_member("rootURL", this.rootURL);
			obj.set_string_member("base_template", this.base_template);
			obj.set_string_member("rootURL", this.rootURL);
			obj.set_string_member("html_gen", this.html_gen);
	}

}
 
 