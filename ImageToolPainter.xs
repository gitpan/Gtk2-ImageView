#include "gtkimageviewperl.h"


MODULE = Gtk2::ImageView::Tool::Painter  PACKAGE = Gtk2::ImageView::Tool::Painter  PREFIX = gtk_image_tool_painter_


GtkIImageTool *
gtk_image_tool_painter_new (class, view)
		GtkImageView *	view
	C_ARGS:
		view
