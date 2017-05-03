package RT::Extension::CustomRole::Visibility;
use strict;
use warnings;

our $VERSION = '0.01';

sub _CurrentURL {
    my $url = $HTML::Mason::Commands::r->path_info;
    $url =~ s!/{2,}!/!g;
    return $url;
}

{
    package RT::CustomRole;

    my $AttributeName = 'HiddenForURLs';

    sub HiddenForURLs {
        my $self = shift;
        my $attr = $self->FirstAttribute($AttributeName);
        return {} if !$attr;
        return $attr->Content;
    }

    sub SetHiddenForURLs {
        my $self = shift;
        my $hidden = shift;

        return $self->SetAttribute(
            Name    => $AttributeName,
            Content => $hidden,
        );
    }

    sub IsHiddenForURL {
        my $self = shift;
        my $url = shift || RT::Extension::CustomRole::Visibility::_CurrentURL();
        return $self->HiddenForURLs->{$url};
    }
}

{
    package RT::Queue;

    sub HiddenCustomRoleIDsForURL {
        my $self = shift;
        my $url = shift;

        my $roles = $self->CustomRoles;
        my @ids;

        while (my $role = $roles->Next) {
            push @ids, $role->Id if $role->IsHiddenForURL($url);
        }

        return @ids;
    }
}

=head1 NAME

RT-Extension-CustomRole-Visibility - manage custom role visibility

=head1 INSTALLATION

RT-Extension-CustomRole-Visibility requires version RT 4.4.0 or later.

=over

=item perl Makefile.PL

=item make

=item make install

This step may require root permissions.

=item Edit your /opt/rt4/etc/RT_SiteConfig.pm

Add this line:

    Plugin( "RT::Extension::CustomRole::Visibility" );

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=item Configure custom role visibility

Visit Admin -> Custom Roles -> Select -> (queue) -> Visibility to
configure the visibility for a custom role.

=back

=head1 AUTHOR

Best Practical Solutions, LLC E<lt>modules@bestpractical.comE<gt>

=head1 BUGS

All bugs should be reported via email to

    L<bug-RT-Extension-CustomRole-Visibility@rt.cpan.org|mailto:bug-RT-Extension-CustomRole-Visibility@rt.cpan.org>

or via the web at

    L<rt.cpan.org|http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-CustomRole-Visibility>.

=head1 COPYRIGHT

This extension is Copyright (C) 2017 Best Practical Solutions, LLC.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
