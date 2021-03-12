###################################################################
#  GTChat 0.95 Alpha Plugin                                       #
#  Written for release 20021101                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin sends user a mail with an authentication code on   #
#  registration. This code has to be used for the first login     #
#  then.                                                          #
###################################################################

package GTChat::Plugins::RegistrationMail::095_01;

use strict;

return bless({});

sub checkProfile
{
	my ($self,$main,$user,$olduser) = @_;

	if (!defined($olduser) && $user->{code} eq "" && exists($user->{email}) && $user->{email} ne '')
	{
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
	}
}

sub userRegistered
{
	my($self,$main,$user) = @_;
	
	if (exists($user->{email}) && $user->{email} ne '')
	{
		$main->{template_vars}{user} = $user;
		$main->sendMailTemplate('mails/registration');
	}
}
