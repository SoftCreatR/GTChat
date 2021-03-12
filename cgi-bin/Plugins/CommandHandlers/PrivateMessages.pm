###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin provides the private messages commands /msg (for   #
#  regular text) and /imgmsg (for images). It manages offline     #
#  messages as well.                                              #
###################################################################

package GTChat::Plugins::PrivateMessages::095_01;
use strict;

return bless({
	command_handlers => {
		'msg' => \&msg_handler,
		'imgmsg' => \&msg_handler,
	},
	template_var_handlers => {
		'offlinemsgs_exist' => \&varhandler,
		'offlinemsgs' => \&varhandler,
	},
});

sub check_gagged
{
	my $main = shift;

	if (exists($main->{current_user}{gagtime}) && $main->{runtime}{now} < $main->{current_user}{gagtime})
	{
		return [$main->createErrorOutput('gagged',{seconds => $main->{current_user}{gagtime}-$main->{runtime}{now}})];
	}
	return undef;
}

sub msg_handler
{
	my($self,$main,$command,$text) = @_;

	if (my $error=check_gagged($main))
	{
		return $error;
	}
	
	my @parts = split(/\s+/,$text);
	my $tonick = shift @parts;
	$text = $main->toHTML(join(' ',@parts));

	return [$main->createErrorOutput('msg_namenotgiven')] if (!defined($tonick));

	return undef if ($text eq '');
	
	my $candidates = $main->getPossibleOnlineUsers($tonick);

	if ($#$candidates>0)    # Too many users online with nick starting like this
	{
		return [$main->createErrorOutput('ambiguousname',{nick => $tonick})];
	}
	elsif ($#$candidates==0)   # User is online
	{
		my $user = $candidates->[0];
		
		return [$main->createErrorOutput('msgtooneself')] if ($user->{name} eq $main->{current_user}{name});

		my $output1 = $main->createOutput(
					{
						template => 'private_sent',
						toname => $user->{name},
						tonick => $user->{nick},
						color => $main->{current_user}{color},
						text => ($command eq 'msg'?$text:''),
						url => ($command eq 'msg'?'':$text),
					});
		my $output2 = $main->createOutput(
					{
						template => 'private',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						color => $main->{current_user}{color},
						text => ($command eq 'msg'?$text:''),
						url => ($command eq 'msg'?'':$text),
					});
		return [$output1->restrictToCurrentUser, $output2->restrictToUser($user->{name})];
	}
	else                      # No user with this nickname online
	{
		$candidates = $main->getPossibleUsernames($tonick);

		if ($#$candidates>1)        # There are too many users with nick starting like this
		{
			return [$main->createErrorOutput('ambiguousname',{nick => $tonick})];
		}
		elsif ($#$candidates<0)     # No user with this nick found
		{
			return [$main->createErrorOutput('unknownname',{nick => $tonick})];
		}
		else                        # User was found but isn't online
		{
			my $toname = $candidates->[0];
			$tonick = $candidates->[1];

			my $line = $main->{runtime}{now}.'|'.$main->toOutputString(
					{
						template => 'private',
						name => $main->{current_user}{name},
						nick => $main->{current_user}{nick},
						color => $main->{current_user}{color},
						text => ($command eq 'msg'?$text:''),
						url => ($command eq 'msg'?'':$text),
					});

			my $filename = unpack("H*",$toname);
			$main->open(local *FILE,'>>'.$main->translateName("memberdir::$filename.msg"));
			print FILE "$line\n";
			$main->close(*FILE);

			my $output = $main->createOutput(
					{
						template => 'offline_sent',
						toname => $toname,
						tonick => $tonick,
						color => $main->{current_user}{color},
						text => ($command eq 'msg'?$text:''),
						url => ($command eq 'msg'?'':$text),
					});
			return [$output->restrictToCurrentUser];
		}
	}
}

sub varhandler
{
	my($self,$main,$var) = @_;
	
	my $filename = unpack("H*",$main->{current_user}{name});
	$main->{template_vars}{offlinemsgs_exist} = -e($main->translateName("memberdir::$filename.msg"));

	return if ($var eq 'offlinemsgs_exist' || !$main->{template_vars}{offlinemsgs_exist});
	
	$main->open(local* FILE,$main->translateName("memberdir::$filename.msg")) || return;
	my @entries = <FILE>;
	$main->close(*FILE);
	unlink($main->translateName("memberdir::$filename.msg"));
	
	$main->{template_vars}{offlinemsgs} = GTChat::Plugins::PrivateMessages::OfflineEnum::095_01::new($main,\@entries);
}

package GTChat::Plugins::PrivateMessages::OfflineEnum::095_01;
use strict;
use vars qw(@ISA);

sub new
{
	my($main,$list) = @_;

	@ISA = ('GTChat::Enum');
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
	return ($self->{opened} && $self->{index} < $#{$self->{list}});
}

sub next
{
	my $self=shift;
	
	return undef unless ($self->{opened} && $self->{index} < $#{$self->{list}});

	$self->{index}++;
	my $string = $self->{list}[$self->{index}];
	$string =~ s/[\n\r]//g;

	my @parts = split(/\|/,$string);
	my $time = shift @parts;

	my $params=$self->{main}->fromOutputString(join('|',@parts));
	$params->{time} = $time;
	
	$self->{main}{template_vars}{params}=$params;

	my $output = "";
	my $data = $self->{main}->parseTemplate('offline/'.$params->{template});
	$data->process($self->{main},\$output);

	return $output;
}

sub close
{
	my $self=shift;
	
	$self->{opened}=0;
}
