###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin sends user a mail with an authentication code if   #
#  he has forgotten his password. This code can be used once      #
#  instead of the password then.                                  #
###################################################################

package GT_Chat::Plugins::Reminder::096_01;

use strict;

return bless({
	action_handlers => {
		'reminder' => \&reminder_handler,
	},
});

sub reminder_handler
{
	my($self,$main) = @_;
	
	$main->{template_vars}{backaddr} = 'javascript:history.back()';

	my $name = $main->{input}{name};
	if (!$main->{input}{is_username})
	{
		$name = $main->getUsername($name);
		$main->fatal_error('usernotfound',{name => $main->{input}{name}}) if (!defined($name));
	}
	my $user = $main->loadUser($name);
	if (!defined($user))
	{
		$main->fatal_error('usernotfound',{name => $main->{input}{name}}) if (!defined($user));
	}
	
	$main->fatal_error('reminder_noemailgiven',{name => $main->{input}{name}}) if (!exists($user->{email}) || $user->{email} !~ /\S/);

	$user->{code} = $main->{current_user}{ip};
	$user->{code} =~ s/\D//g;
	$user->{code} = substr($user->{id}, length($user->{id})-10)+0;

	srand;
	my $rand = rand;
	$rand =~ s/\D//g;
	$rand = substr($rand, length($rand)-10);
	$user->{code} ^= $rand+0;

	$user->{code} ^= $main->{runtime}{now}+0;
	
	$user->{code} = $main->crypt($user->{id},pack("a2",rand(256),rand(256)));
	$user->{code} =~ s/\W//g;
	
	$main->saveUser($user);
	
	$main->{template_vars}{user} = $user;
	$main->sendMailTemplate('mails/reminder');
	
	$main->printTemplate('reminder_success');
}
