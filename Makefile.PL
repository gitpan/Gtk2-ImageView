use 5.008;
use ExtUtils::MakeMaker;
use Cwd;
use File::Spec;

# minimum required version of dependancies we need to build
our %build_reqs = (
	'perl-ExtUtils-Depends'   => '0.1',
	'perl-ExtUtils-PkgConfig' => '0.1',
	'perl-Glib'               => '1.00',
	'perl-Gtk2'               => '1.00',
	'GtkImageView'            => '1.6.0',
);

# minimum required version of dependancies we need to run
our %runtime_reqs = (
	'GtkImageView' => undef,
);

# Writing a fake Makefile ensures that CPAN will pick up the correct
# dependencies and install them.
unless (eval "use ExtUtils::Depends;"
           . "use ExtUtils::PkgConfig;"
           # just seeing if Glib is available isn't enough, make sure
           # it's recent enough, too 
           . "use Glib '$build_reqs{'perl-Glib'}';"
           . "use Glib::MakeHelper;"
           . "use Gtk2 '$build_reqs{'perl-Gtk2'}';"
           . "use Gtk2::CodeGen;"
           . "1") {
   warn "$@\n";
   WriteMakefile(
         PREREQ_FATAL => 1,
         PREREQ_PM    => {
            Glib::                => $build_reqs{'perl-Glib'},
            Gtk2::                => $build_reqs{'perl-Gtk2'},
            ExtUtils::Depends::   => $build_reqs{'perl-ExtUtils-Depends'},
            ExtUtils::PkgConfig:: => $build_reqs{'perl-ExtUtils-PkgConfig'},
         },
   );
   exit 1; # not reached
}

%pkgcfg = ExtUtils::PkgConfig->find ('gtkimageview >= '
                                                    . $build_reqs{GtkImageView});

$runtime_reqs{GtkImageView} = $pkgcfg{modversion};

mkdir 'build', 0777;

chomp(my $includes = `pkg-config --variable includedir gtkimageview`);
my @headers = glob($includes . "/gtkimageview/*.h");

#
# autogeneration
#
Gtk2::CodeGen->parse_maps('gtkimageviewperl');
Gtk2::CodeGen->write_boot(glob => '*.xs', ignore => '^Gtk2::ImageView$');

our @xs_files = <*.xs>;
our %pm_files = ('ImageView.pm' => '$(INST_LIBDIR)/ImageView.pm',);
our %pod_files = Glib::MakeHelper->do_pod_files (@xs_files);
our @typemaps = qw(build/gtkimageviewperl.typemap);
our @headers = qw(gtkimageviewperl.h
                   build/gtkimageviewperl-autogen.h);

# now we're ready to start creating the makefile.
# we need to use ExtUtils::Depends to get relevant information out of
# the Glib extension, and to save config information for other modules which
# will chain from this one.

my $depends = ExtUtils::Depends->new ('Gtk2::ImageView', 'Gtk2', 'Glib');
$depends->set_inc ($pkgcfg{cflags});
$depends->set_libs ($pkgcfg{libs});
$depends->add_xs (@xs_files);
$depends->add_pm (%pm_files);
my $cwd = cwd();
$depends->add_typemaps (map {File::Spec->catfile($cwd,$_)} @typemaps);

$depends->install (@headers);

$depends->save_config ('build/IFiles.pm');

WriteMakefile(
    NAME            => 'Gtk2::ImageView',
    VERSION_FROM    => 'ImageView.pm', # finds $VERSION
    ABSTRACT        => 'Perl bindings for the GtkImageView widget',
    XSPROTOARG      => '-noprototypes',
    MAN3PODS        => \%pod_files,
    $depends->get_makefile_vars,
);

package MY;

sub postamble {
	return Glib::MakeHelper->postamble_clean ()
             . Glib::MakeHelper->postamble_docs_full (
		DEPENDS => $depends,
		COPYRIGHT => "Copyright (C) 2007 by Jeffrey Ratcliffe.\n\nThis software is licensed under the GPL-3; see L<Gtk2::ImageView> for a full notice.",
               )
             . Glib::MakeHelper->postamble_rpms (
                'GTK_IMAGE_VIEW' => $build_reqs{'GtkImageView'},
                'PERL_EXTUTILS_DEPENDS' =>
 			$build_reqs{'perl-ExtUtils-Depends'},
 		'PERL_EXTUTILS_PKGCONFIG' =>
 			$build_reqs{'perl-ExtUtils-PkgConfig'},
 		'PERL_GLIB' => $build_reqs{'perl-Glib'},
 		'PERL_GTK' => $build_reqs{'perl-Gtk2'},
 	       )
 	     ."
realclean ::
	-rm -Rf build
";
}
package MAIN;
