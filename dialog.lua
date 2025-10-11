if love.system.getOS() == "Linux" then

local ffi = require 'ffi'
local gtk = ffi.load 'gtk-3'
ffi.cdef [[

typedef void GtkDialog;
typedef void GtkWidget;
typedef void GtkWindow;
typedef void GtkFileChooser;

typedef int gint;
typedef char gchar;
typedef bool gboolean;

typedef enum
{
  GTK_FILE_CHOOSER_ACTION_OPEN,
  GTK_FILE_CHOOSER_ACTION_SAVE,
  GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
  GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER
} GtkFileChooserAction;

typedef enum
{
  GTK_RESPONSE_NONE         = -1,
  GTK_RESPONSE_REJECT       = -2,
  GTK_RESPONSE_ACCEPT       = -3,
  GTK_RESPONSE_DELETE_EVENT = -4,
  GTK_RESPONSE_OK           = -5,
  GTK_RESPONSE_CANCEL       = -6,
  GTK_RESPONSE_CLOSE        = -7,
  GTK_RESPONSE_YES          = -8,
  GTK_RESPONSE_NO           = -9,
  GTK_RESPONSE_APPLY        = -10,
  GTK_RESPONSE_HELP         = -11
} GtkResponseType;

void gtk_init (
    int *argc,
    char ***argv
);

gboolean gtk_events_pending (
    void
);

gboolean gtk_main_iteration (
    void
);

GtkWidget * gtk_file_chooser_dialog_new (
    const gchar *title,
    GtkWindow *parent,
    GtkFileChooserAction action,
    const gchar *first_button_text,
    ...
);

gint gtk_dialog_run (
    GtkDialog *dialog
);

void gtk_widget_destroy (
    GtkWidget *widget
);

gchar * gtk_file_chooser_get_filename (
    GtkFileChooser *chooser
);

gboolean gtk_file_chooser_set_current_folder (
    GtkFileChooser *chooser,
    const gchar *filename
);
]]

local function show (action, button, title, start_dir)
    gtk.gtk_init(nil, nil)

    local d = gtk.gtk_file_chooser_dialog_new(
        title,
        nil,
        action,
        button, ffi.cast('const gchar *', gtk.GTK_RESPONSE_OK),
        '_Cancel', ffi.cast('const gchar *', gtk.GTK_RESPONSE_CANCEL),
        nil)

		if start_dir then
			gtk.gtk_file_chooser_set_current_folder(d,start_dir)
		end
        
    local response = gtk.gtk_dialog_run(d)
    local filename = gtk.gtk_file_chooser_get_filename(d)

    gtk.gtk_widget_destroy(d)

    while gtk.gtk_events_pending() do
        gtk.gtk_main_iteration()
    end
    
    if response == gtk.GTK_RESPONSE_OK then
        return filename ~= nil and ffi.string(filename) or nil
    end
end

local function save (title, dir)
    return show(gtk.GTK_FILE_CHOOSER_ACTION_SAVE,
        '_Save', title or 'Save As', dir)
end

local function open (title, dir)
    return show(gtk.GTK_FILE_CHOOSER_ACTION_OPEN,
        '_Open', title or 'Open', dir)
end

return {
    save = save,
    open = open,
}

elseif love.system.getOS() == "Windows" then

local ffi = require "ffi"

ffi.cdef [[
typedef unsigned long DWORD;
typedef unsigned short WORD;
typedef const char *LPCSTR;
typedef char *LPSTR;
typedef void *HWND;
typedef void *HINSTANCE;
typedef long LPARAM;    
typedef int BOOL;      

typedef struct {
  DWORD lStructSize;
  HWND hwndOwner;
  HINSTANCE hInstance;
  LPCSTR lpstrFilter;
  LPSTR lpstrCustomFilter;
  DWORD nMaxCustFilter;
  DWORD nFilterIndex;
  LPSTR lpstrFile;
  DWORD nMaxFile;
  LPSTR lpstrFileTitle;
  DWORD nMaxFileTitle;
  LPCSTR lpstrInitialDir;
  LPCSTR lpstrTitle;
  DWORD Flags;
  WORD nFileOffset;
  WORD nFileExtension;
  LPCSTR lpstrDefExt;
  LPARAM lCustData;
  void *lpfnHook;
  LPCSTR lpTemplateName;
  void *pvReserved;
  DWORD dwReserved;
  DWORD FlagsEx;
} OPENFILENAMEA;

bool GetOpenFileNameA(OPENFILENAMEA *ofn);
bool GetSaveFileNameA(OPENFILENAMEA *ofn);
]]

local comdlg32 = ffi.load("Comdlg32")

local function windows_open_dialog(title, initial_dir)
    local buffer = ffi.new("char[260]", "") -- MAX_PATH
    local ofn = ffi.new("OPENFILENAMEA")
    ofn.lStructSize = ffi.sizeof(ofn)
    ofn.lpstrFile = buffer
    ofn.nMaxFile = 260
    ofn.lpstrTitle = title
    ofn.lpstrInitialDir = initial_dir
    ofn.Flags = 0x00000008 -- OFN_PATHMUSTEXIST

    if comdlg32.GetOpenFileNameA(ofn) then
        return ffi.string(ofn.lpstrFile)
    else
        return nil
    end
end

local function windows_save_dialog(title, initial_dir)
    local buffer = ffi.new("char[260]", "")
    local ofn = ffi.new("OPENFILENAMEA")
    ofn.lStructSize = ffi.sizeof(ofn)
    ofn.lpstrFile = buffer
    ofn.nMaxFile = 260
    ofn.lpstrTitle = title
    ofn.lpstrInitialDir = initial_dir
    ofn.Flags = 0x00000002 -- OFN_OVERWRITEPROMPT

    if comdlg32.GetSaveFileNameA(ofn) then
        return ffi.string(ofn.lpstrFile)
    else
        return nil
    end
end

return {
	save = windows_save_dialog,
	open = windows_open_dialog,
}

else
	error("Unsupported operating system " .. tostring(love.system.getOS()))
end
