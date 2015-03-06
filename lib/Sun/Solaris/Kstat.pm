# Copyright (C) 2011 Gunnar Beutner
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

package Sun::Solaris::Kstat;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
	new update
);

our $VERSION = '0.01';

sub new {
  my $package = shift;
  return bless({}, $package);
}

sub update {
  my $self = shift;

  my $kstat_path = "/proc/spl/kstat/";

  opendir(KDIR, $kstat_path) or die $!;

  my @modules = readdir(KDIR);
  my $module;
  foreach $module (@modules) {
    if ($module eq "." || $module eq "..") {
      next;
    }

    $self->{$module} = {};
    $self->{$module}{0} = {};

    opendir(MODDIR, $kstat_path . $module) or die $!;

    my @files = readdir(MODDIR);
    my $file;
    foreach $file (@files) {
      if ($file eq "." || $file eq ".." || $file eq "dbufs") {
        next;
      }

      $self->{$module}{0}{$file} = {};

      open FILE, $kstat_path . "/" . $module . "/" . $file or die $!;

      while (<FILE>) {
        if ($_ =~ /^([^ ]+) *(\d+) *(\d+)$/) {
          $self->{$module}{0}{$file}{$1} = $3;
        }
      }

      close FILE;
    }

    closedir(MODDIR);
  }

  closedir(KDIR);

  return 0;
}

1;
__END__

=head1 NAME

Sun::Solaris::Kstat - Solaris-compatible kstat interface

=head1 SYNOPSIS

  use Sun::Solaris::Kstat;
  my $kstat = Sun::Solaris::Kstat->new;
  $kstat->update();
  $kstat->{"zfs"}{0}{"arcstats"}{"hits"}

=head1 DESCRIPTION

This module provides an interface for the Linux ZFS kernel module that is
compatible with the Sun::Solaris::Kstat Perl module found on Solaris systems.

=head1 SEE ALSO

L<http://developers.sun.com/solaris/articles/kstat_part2.html>

=head1 AUTHOR

Gunnar Beutner	<gunnar@beutner.name>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Gunnar Beutner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


=cut
