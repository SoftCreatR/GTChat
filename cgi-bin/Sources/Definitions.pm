###################################################################
#  GTChat GTChat 0.96 Alpha Build 20060923 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.softcreatr.de)     #
###################################################################

package GT_Chat::Definitions;

bless({
	action_handlers => {
		info => 'sourcedir::Info.pm',
		register => 'sourcedir::Register.pm',
		login => 'sourcedir::Login.pm',
		send => 'sourcedir::Send.pm',
		messages => 'sourcedir::Messages.pm',
		modifyprofile => 'sourcedir::ModifyProfile.pm',
		deleteuser => 'sourcedir::ModifyProfile.pm',
		modifyroom => 'sourcedir::ModifyRoom.pm',
		deleteroom => 'sourcedir::ModifyRoom.pm',
	},

	var_handlers => {
		'environment' => 'sourcedir::environment_loader.pm',
		'messages' => 'sourcedir::Messages.pm',
		'runtime.hiddenfields' => 'sourcedir::Stash.pm',
	},

	template_blocks => {
		IF => 'sourcedir::block_handlers.pm',
		FOREACH => 'sourcedir::block_handlers.pm',
		FOR => 'sourcedir::block_handlers.pm',
	},

	template_commands => {
		IIF => 'sourcedir::block_handlers.pm',
		GET => 'sourcedir::Stash.pm',
		GET_JS => 'sourcedir::Stash.pm',
		GET_ESCAPED => 'sourcedir::Stash.pm',
		NEED => 'sourcedir::Stash.pm',
		UPDATE => 'sourcedir::Stash.pm',
		GETLNG => 'sourcedir::Stash.pm',
		GETLNG_JS => 'sourcedir::Stash.pm',
		GETLNG_ESCAPED => 'sourcedir::Stash.pm',
		NEEDLNG => 'sourcedir::Stash.pm',
		UPDATELNG => 'sourcedir::Stash.pm',
		SET => 'sourcedir::Stash.pm',
		IMAGE => 'sourcedir::tag_handlers.pm',
		COPYRIGHT => 'sourcedir::tag_handlers.pm',
		NEED_PERMISSION => 'sourcedir::tag_handlers.pm',
		MESSAGE => 'sourcedir::tag_handlers.pm',
		ERROR => 'sourcedir::tag_handlers.pm',
	},

	subs => {
		sendOutputStrings => 'sourcedir::Send.pm',
		toOutputString => 'sourcedir::Send.pm',
		fromOutputString => 'sourcedir::Messages.pm',
		get => 'sourcedir::Stash.pm',
		getEx => 'sourcedir::Stash.pm',
		set => 'sourcedir::Stash.pm',
		update => 'sourcedir::Stash.pm',
		getCopyrightText => 'sourcedir::tag_handlers.pm',
		getImageText => 'sourcedir::tag_handlers.pm',
	},
})
