 

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
		//NOOP
	}
	public override string saveJson(Json.Object obj
	{
	//NOOP
	}

}
 
 