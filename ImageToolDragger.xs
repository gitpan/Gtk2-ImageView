#include "gtkimageviewperl.h"


MODULE = Gtk2::ImageView::Tool::Dragger  PACKAGE = Gtk2::ImageView::Tool::Dragger  PREFIX = gtk_image_tool_dragger_

=for object Gtk2::ImageView::Tool::Dragger Default image tool for panning the image.

=head1 DESCRIPTION

Gtk2::ImageView::Tool::Dragger is the default image tool for Gtk2::ImageView. Its only feature is that it can drag the image around.

=cut


=for apidoc

Creates and returns a new dragger tool.

=over

=item view : a Gtk2::ImageView.

=back

=head3 Returns

=over

=item a new Gtk2::ImageView::Tool::Dragger

=back

=cut
GtkIImageTool *
gtk_image_tool_dragger_new (class, view)
		GtkImageView *	view
	C_ARGS:
		view
