###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::block_handlers;
use strict;

bless({
	template_block_handlers => {
		FOREACH => \&foreach_handler,
		FOR => \&for_handler,
		IF => \&if_handler,
	},
	block_switch_tags => {
		FOREACH => 'NOTLAST',
		FOR => 'NOTLAST',
		IF => 'ELSE',
	},
	block_end_tags => {
		FOREACH => 'ENDFOR',
		FOR => 'ENDFOR',
		IF => 'ENDIF',
	},
	template_command_handlers => {
		IIF => \&iif_handler,
	},
});

sub getVar
{
	my($main,$var) = @_;
	if ($var =~ /^permission\(([^)]+)\)$/i)
	{
		$var = $main->hasPermission(getVar($main,$1));
	}
	elsif ($var =~ /^(!?)\$(.+)/)
	{
		$var = $main->getEx($2) ;
		$var = !$var if $1;
	}

	return $var;
}

sub test_condition
{
	my($main,$condition) = @_;

	my $newcondition = '';
	while ($condition =~ /(.+?)( or | and |$)/gi)
	{
		my ($part,$op1) = ($1,$2);

		if ($part =~ /^\s*(.+?)\s*(<=|>=|!=|==| eq | ne |[<>=])\s*(.+)\s*/i)
		{
			my ($var1,$op2,$var2)=($1,$2,$3);
			$var1 = getVar($main,$var1);
			$var1 = '' unless defined($var1);
			$var1 =~ s/[\\\']/\\$&/g;
			$var2 = getVar($main,$var2);
			$var2 = '' unless defined($var2);
			$var2 =~ s/[\\\']/\\$&/g;
			$part = eval("'$var1'".lc($op2)."'$var2'")?1:0;
		}
		else
		{
			$part = getVar($main,$part);
			$part = ($part?1:0);
		}
		$newcondition .= $part.lc($op1);
	}
	return eval($newcondition);
}

sub if_handler
{
	my($self,$main,$params,$content,$content2,$output) = @_;

	my($tag,$condition) = @$params;
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line},tag => $tag}) if (!defined($condition));

	if (test_condition($main,$condition))
	{
		$content->process($main,$output);
	}
	elsif (defined($content2))
	{
		$content2->process($main,$output);
	}
}

sub iif_handler
{
	my($self,$main,$params,$output) = @_;

	my($tag,$condition,$true,$false) = @$params;
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => $tag}) if (!defined($condition) || !defined($true));

	if (test_condition($main,$condition))
	{
		$$output .= $true;
	}
	elsif (defined($false))
	{
		$$output .= $false;
	}
}

sub foreach_handler
{
	my($self,$main,$params,$content,$content2,$output) = @_;

	my($tag,$counter,$var) = @{$params};

	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => $tag}) if (!defined($counter) || !defined($var));

	$counter =~ s/^\$//;
	$var = $main->getEx($1) if ($var =~ /^\$(.+)/);

	my $first=1;
	if (ref($var) eq "HASH")
	{
		foreach my $key (sort keys %$var)
		{
			$content2->process($main,$output) if (!$first && defined($content2));
			$first = 0;

			$main->set("$counter.name",$key);
			$main->set("$counter.value",$var->{$key});
			$content->process($main,$output);
		}
	}
	elsif (ref($var) eq "ARRAY")
	{
		foreach my $element (@$var)
		{
			$content2->process($main,$output) if (!$first && defined($content2));
			$first = 0;

			$main->set("$counter",$element);
			$content->process($main,$output);
		}
	}
	elsif (UNIVERSAL::isa($var,"GT_Chat::Enum"))
	{
		$var->open;
		while ($var->hasNext)
		{
			$content2->process($main,$output) if (!$first && defined($content2));
			$first = 0;

			my $next = $var->next;
			if (defined($next))
			{
				$main->set($counter,$next);
				$content->process($main,$output);
			}
		}
		$var->close;
	}
}

sub for_handler
{
	my($self,$main,$params,$content,$content2,$output) = @_;

	my($tag,$counter,$from,$to) = @{$params};
	$main->fatal_error('tag_notenoughparameters',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}, tag => $tag}) if (!defined($counter) || !defined($from) || !defined($to));

	$counter =~ s/^\$//;
	$from = $main->getEx($1) if ($from =~ /^\$(.+)/);
	$to = $main->getEx($1) if ($to =~ /^\$(.+)/);
	$main->fatal_error('tag_for_invalidranges',{template => $main->{template_vars}{template_name}, line => $main->{template_vars}{template_line}}) if ($to < $from);

	my $first = 1;
	for (my $i = $from;$i <= $to;$i++)
	{
		$content2->process($main,$output) if (!$first && defined($content2));
		$first = 0;

		$main->set($counter,$i);
		$content->process($main,$output);
	}
}
