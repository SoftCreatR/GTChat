###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Stash;
use strict;

bless({
	template_command_handlers => {
		GET => \&get_handler,
		GET_JS => \&get_handler,
		GET_ESCAPED => \&get_handler,
		NEED => \&get_handler,
		UPDATE => \&get_handler,
		GETLNG => \&get_handler,
		GETLNG_JS => \&get_handler,
		GETLNG_ESCAPED => \&get_handler,
		NEEDLNG => \&get_handler,
		UPDATELNG => \&get_handler,
		SET => \&set_handler,
	},
	template_var_handlers => {
		'runtime.hiddenfields' => \&setHiddenFields,
	},
});

sub getInternal
{
	my $ret = shift;
	foreach (@_)
	{
		if (ref($ret) eq 'HASH' || ref($ret) eq __PACKAGE__)
		{
			if (/^(.+)\[(-?\d+)\]$/)
			{
				$ret = $ret->{$1}[$2];
			}
			else
			{
				$ret = $ret->{$_};
			}
		}
		elsif (ref($ret) eq 'ARRAY')
		{
			if (/^-?\d+$/)
			{
				$ret = $ret->[$_];
			}
			elsif ($_ eq 'length')
			{
				$ret = $#$ret + 1;
			}
			elsif ($_ eq 'last')
			{
				$ret = $#$ret;
			}
			else
			{
				return undef;
			}
		}
		else
		{
			return undef;
		}
	}
	return $ret;
}

sub setInternal
{
	my $hash = shift;
	my $value = pop;
	my $name = pop;

	foreach (@_)
	{
		if (/^(.+)\[(-?\d+)\]$/)
		{
			$hash->{$1}[$2] = {} unless (ref($hash->{$1}[$2]) eq "HASH" || ref($hash->{$1}[$2]) eq __PACKAGE__);
			$hash = $hash->{$1}[$2];
		}
		else
		{
			$hash->{$_} = {} unless (ref($hash->{$_}) eq "HASH" || ref($hash->{$_}) eq __PACKAGE__);
			$hash = $hash->{$_};
		}
	}
	if ($name =~ /^(.+)\[(-?\d+)\]$/)
	{
		$hash->{$1}[$2] = $value;
	}
	else
	{
		$hash->{$name} = $value;
	}
}

sub get
{
	my($main,$var) = @_;

	$var =~ s/\(\$(.+?)\)/getInternal($main->{template_vars},split(\/\.\/,$1))/ge;
	return getInternal($main->{template_vars},split(/\./,$var));
}

sub getVarHandlers
{
	my $main = shift;

	my $hashmodule = $main->{modules}{'sourcedir::joinedhash.pm'};
	$main->{var_handlers} = $hashmodule->new($main->{definitions}{var_handlers}, $main->{settings}{'custom_var_handlers'});
}

sub getEx
{
	my($main,$var) = @_;

	getVarHandlers($main) unless $main->{var_handlers};

	my $ret = $main->get($var);
	if (!defined($ret) && exists($main->{var_handlers}{$var}))
	{
		my $handler = $main->{modules}{$main->{var_handlers}{$var}};
		return $ret unless (exists($handler->{template_var_handlers}{$var}));
		&{$handler->{template_var_handlers}{$var}}($handler, $main, $var);
		$ret = $main->get($var);
	}
	return $ret;
}

sub update
{
	my($main,$var) = @_;

	getVarHandlers($main) unless $main->{var_handlers};

	if (exists($main->{var_handlers}{$var}))
	{
		my $handler = $main->{modules}{$main->{var_handlers}{$var}};
		return unless (exists($handler->{template_var_handlers}{$var}));
		&{$handler->{template_var_handlers}{$var}}($handler, $main, $var);
	}
}

sub set
{
	my ($main,$var,$value) = @_;

	$var =~ s/\(\$(.+?)\)/getInternal($main->{template_vars},split(\/\.\/,$1))/ge;
	setInternal($main,'template_vars',split(/\./,$var),$value);
}

sub get_handler
{
	my($self,$main,$params,$output) = @_;

	my($tag,$var,$var2) = @$params;
	my $lng;
	if ($tag =~ /LNG/)
	{
		$lng = $var;
		$var = $var2;
	}
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line},tag => ${$params}[0]}) if (!defined($var));

	$lng = $main->getEx($1) if (defined($lng) && $lng =~ /^\$(.+)/);
	my $prefix = (defined($lng) ? "settings.language_dependent.$lng." : "");

	if ($var =~ /^\$(.+)/)
	{
		my $varname = $1;
		if ($tag =~ /UPDATE/)
		{
			$main->update($prefix.$varname) ;
		}
		else
		{
			$var = $main->getEx($prefix.$varname);
		}
	}

	if ($tag =~ /JS/ && defined($var))
	{
		$var =~ s/\r//g;
		$var =~ s/[\\'"]/\\$&/g;
		$var =~ s/\n/\\n/g;
		$var =~ s/\t/\\t/g;
		$var =~ s/<\/script/<\/'+'script/g;
	}
	elsif ($tag =~ /ESCAPED/ && defined($var))
	{
		$var =~ s/\W/"%".unpack("H2",$&)/eg;
	}


	$$output .= $var if ($tag !~ /NEED/ && $tag !~ /UPDATE/ && defined($var) && !ref($var));
}

sub set_handler
{
	my($self,$main,$params,$output) = @_;

	my($tag,$var,$value) = @$params;
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line},tag => ${$params}[0]}) if (!defined($var));

	$value = $main->getEx($1) if ($value =~ /^\$(.+)/);
	$var =~ s/^\$//g;

	$main->set($var,$value);
}

sub setHiddenFields
{
	my($self,$main,$var) = @_;

	my $ret = '';
	$ret .= "<input type=\"hidden\" name=\"id\" value=\"$main->{runtime}{id}\"/>" unless $main->{runtime}{cookieid};

	my @forwarded = ('language');
	push @forwarded, @{$main->{settings}{forward_params}} if (exists($main->{settings}{forward_params}));

	foreach (@forwarded)
	{
		my ($key,$value) = ($_,$main->{input}{$_});

		$key="" unless defined($key);
		$value="" unless defined($value);

		$key = $main->toHTML($key);
		$value = $main->toHTML($value);

		$ret .= "<input type=\"hidden\" name=\"$key\" value=\"$value\"/>";
	}
	$main->{runtime}{hiddenfields} = $ret;
}
