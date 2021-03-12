###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin loads the file <language>.permissions and provides #
#  the template variables with the descriptions of the            #
#  permissions.                                                   #
###################################################################

package GTChat::Plugins::Permissions::095_02;
use strict;
use vars qw(@ISA);

@ISA = ('GTChat::Enum');

bless({
	template_var_handlers => {
		'permissions' => \&handler,
		'permissions_count' => \&handler,
		'commandpermissions' => \&handler,
		'commandpermissions_count' => \&handler,
	},
});

sub handler
{
	my($self,$main,$var) = @_;

	my @list;
	if ($var =~ /command/)
	{
		@list = sort map {$main->{settings}{hide_commandpermissions}{$_} ? () : "command.$_|/$_"} keys %{$main->{settings}{custom_command_handlers}};
		$var = 'commandpermissions';
	}
	else
	{
		$main->open(local* FILE, $main->translateName($main->{runtime}{language}.'.permissions')) || $main->fatal_error('couldnotopen',{file => $main->translateName($main->{runtime}{language}.'.permissions')});
		@list = <FILE>;
		$main->close(*FILE);
		$var = 'permissions';
	}

	$main->{template_vars}{$var} = new($main,\@list);
	$main->{template_vars}{$var.'_count'} = $#list+1;
}

sub new
{
	my($main,$list) = @_;

	my $enum=$main->{modules}{'sourcedir::Enum.pm'};

	return bless({
		list => $list,
		main => $main,
		opened => 0,
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
	
	my $entry = $self->{list}[$self->{index}];
	$entry =~ s/[\n\r]//g;

	my %ret = ();
	($ret{name},$ret{description}) = split(/\|/,$entry);
	$ret{description} = $self->{main}->toHTML($ret{description});
	
	my $user = $self->{main}{template_vars}{user_information}||$self->{main}{current_user};

	$ret{group} = (defined($self->{main}{settings}{permissions}{$ret{name}}) ? $self->{main}{settings}{permissions}{$ret{name}} : ($ret{name} =~ /\./ ? -1 : 256));
	$ret{haspermission} = $self->{main}->hasPermission($ret{name},$user);
	$ret{defaultpermission} = $self->{main}->hasPermission($ret{name},{tempgroup => $user->{tempgroup}});
	$ret{individualpermission} = (defined($user) ? $user->{permissions}{$ret{name}} : 0);
	
	return \%ret;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}
