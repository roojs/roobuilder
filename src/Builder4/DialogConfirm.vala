    static DialogConfirm  _DialogConfirm;

    public class DialogConfirm : Object
    {
        public Gtk.MessageDialog el;
        private DialogConfirm  _this;

        public static DialogConfirm singleton()
        {
            if (_DialogConfirm == null) {
                _DialogConfirm= new DialogConfirm();
            }
            return _DialogConfirm;
        }

            // my vars (def)

        // ctor
        public DialogConfirm()
        {
            _this = this;
            this.el = new Gtk.MessageDialog( null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO, "Test" );

            // my vars (dec)

            // set gobject values
            this.el.title = "Please Confirm ";
            this.el.name = "DialogConfirm";
            this.el.modal = true;
            this.el.use_markup = true;

            //listeners
            this.el.close_request.connect( (event) => {
                this.el.response(Gtk.ResponseType.CANCEL);
                this.el.hide();
                return true;
                
            });
        }

        // user defined functions
        public void showIt // caller needs to connect to the  response -  to get the result.
          
          (string title, string msg) {
             //if (!this.el) { this.init(); } 
             //this.success = success;
             this.el.title = title;
            this.el.text =  msg;
            this.el.show();
           
         
        }
    }
