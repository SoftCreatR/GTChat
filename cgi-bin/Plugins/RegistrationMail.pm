###################################################################
#  GT-Chat 0.96 Alpha Plugin                                       #
#  Written for release whatever                                   #
#  Author: Wladimir Palant                                        #
#                                                                 #
#  This plugin sends user a mail with an authentication code on   #
#  registration. This code has to be used for the first login     #
#  then.                                                          #
###################################################################

package GT_Chat::Plugins::RegistrationMail::096_01;

use strict;

return bless({});

sub beforeUserSave
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

sub afterUserSave
{
	my($self,$main,$user,$olduser) = @_;
	
	if (!defined($olduser) && exists($user->{email}) && $user->{email} ne '')
	{
		$main->{template_vars}{user} = $user;
		$main->sendMailTemplate('mails/registration');
	}
}
