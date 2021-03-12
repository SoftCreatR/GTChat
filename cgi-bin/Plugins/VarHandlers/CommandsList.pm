###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin loads the file <language>.commands and provides    #
#  the template variables with the descriptions of all allowed    #
#  commands.                                                      #
###################################################################

package GT_Chat::Plugins::CommandsList::096_01;
use strict;
use vars qw(@ISA);

@ISA = ('GT_Chat::Enum');

bless({
	template_var_handlers => {
		'commandslist' => \&handler,
		'commands_count' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;

	my $descriptions = $main->{modules}{$main->{runtime}{language}.'.commands'};

	my %hide = ();
	if ($descriptions->{__hide})
	{
		foreach (@{$descriptions->{__hide}})
		{
			$hide{$_} = 1;
		}
	}

	my %commands = ();
	foreach (keys %{$main->{settings}{custom_command_handlers}},keys %{$main->{settings}{jscommands}})
	{
		if (!$hide{$_})
		{
			$commands{$_} = $descriptions->{$_};
			$commands{$_} = {description => '',params => ''} unless ref($commands{$_}) eq 'HASH';
			$commands{$_}->{command} = $_;
		}
	}
	
	my @commands = ();
	foreach (@{$descriptions->{__order}})
	{
		if (exists($commands{$_}) &&  (!exists($main->{settings}{permissions}{"command.$_"}) || $main->hasPermission("command.$_")))
		{
			push @commands,$commands{$_};
			delete $commands{$_};
		}
	}
	
	foreach (keys %commands)
	{
		push @commands,$commands{$_} if !exists($main->{settings}{permissions}{"command.$_"}) || $main->hasPermission("command.$_");
	}

	$main->{template_vars}{commandslist} = new($main,\@commands);
	$main->{template_vars}{commands_count} = $#commands+1;
}

sub new
{
	my($main,$list) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	return bless({
		list => $list,
		opened => 0,
		main => $main,
		index => -1,
	});
}

sub open
{
	my $self=shift;
	
	$self->close if $self->{opened};
	
	$self->{index} = -1;
	$self->{opened} = 1;
}

sub hasNext
{
	my $self=shift;
	return $self->{opened} && $self->{index}<$#{$self->{list}};
}

sub next
{
	my $self=shift;
	
	return undef if (!$self->{opened} || $self->{index}>=$#{$self->{list}});
	
	$self->{index}++;
	
	my $ret = $self->{list}[$self->{index}];

	$ret->{permission} = -1;
	$ret->{permission} = $self->{main}{settings}{permissions}{"command.$ret->{command}"} if exists($self->{main}{settings}{permissions}{"command.$ret->{command}"});
	
	$ret->{aliases} = [];
	foreach (keys %{$self->{main}{settings}{aliases}})
	{
		push @{$ret->{aliases}},$self->{main}->toHTML($_) if $self->{main}{settings}{aliases}{$_} eq $ret->{command};
	}
	
	$ret->{command} = $self->{main}->toHTML($ret->{command});
	$ret->{params} = $self->{main}->toHTML($ret->{params});
	$ret->{description} = $self->{main}->toHTML($ret->{description});

	return $ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}
