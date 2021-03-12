###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::tag_handlers;
use strict;

bless({
	template_command_handlers => {
		COPYRIGHT => \&copyright_handler,
		IMAGE => \&image_handler,
		NEED_PERMISSION => \&permission_handler,
		MESSAGE => \&message_handler,
		ERROR => \&message_handler,
	},
});

sub getCopyrightText
{
	my $main = shift;

	return 'GT-Chat '.$main->{VERSION}.' (c) 2006 by <a href="http://www.gt-chat.de" target="_blank">Sascha Heldt</a>';
}

sub getImageText
{
	my($main,$image,$additional) = @_;

	my ($width,$height);
	($width,$height) = @{$main->{settings}{images}{$image}} if defined($main->{settings}{images}{$image});
	$width = (defined($width) ? " width=$width": '');
	$height = (defined($height) ? " height=$height": '');

	my $dir = $main->{settings}{urls}{imagesurl};

	$additional = (defined($additional) ? ' '.$additional : '');

	return "<img src=\"$dir$image.gif\" border=0$width$height$additional>";
}

sub copyright_handler
{
	my($self,$main,$params,$output) = @_;

	$$output .= $main->getCopyrightText;
}

sub image_handler
{
	my($self,$main,$params,$output) = @_;

	my $image = $params->[1];
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => ${$params}[0]}) if (!defined($image));

	$image = $main->getEx($1) if ($image =~ /^\$(.+)/);

	$$output .= $main->getImageText($image,$params->[2]);
}

sub permission_handler
{
	my($self,$main,$params,$output) = @_;

	my $permissionname = ${$params}[1];
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => ${$params}[0]}) if (!defined($permissionname));

	$permissionname = $main->getEx($1) if ($permissionname =~ /^\$(.+)/);

	$main->fatal_error('nopermission') unless $main->hasPermission($permissionname);
}

sub addParameters
{
	my ($main,$params,$hash) = @_;

	foreach (@$params)
	{
		my @parts = split(/=/);
		my $key = shift @parts;
		my $val = join('=',@parts);

		$key = $main->getEx($1) if ($key =~ /^\$(.+)/);
		$val = $main->getEx($1) if ($val =~ /^\$(.+)/);
		if (UNIVERSAL::isa($key,'HASH'))
		{
			foreach (keys (%$key))
			{
				$hash->{$_} = $key->{$_};
			}
		}
		elsif (UNIVERSAL::isa($key,'ARRAY'))
		{
			addParameters($main,$key,$hash);
		}
		elsif (!ref($key) && !ref($val))
		{
			$hash->{$key} = $val;
		}
	}
}

sub message_handler
{
	my($self,$main,$params,$output) = @_;

	my ($tag,$name) = @$params;
	$name = $main->getEx($1) if ($name =~ /^\$(.+)/);

	my %params = ();
	addParameters($main,$params,\%params);

	if ($tag eq 'MESSAGE')
	{
		my $message = $main->getMessage($name,\%params);
		$$output .= $message if defined($message);
	}
	else
	{
		$main->fatal_error($name, \%params);
	}
}
