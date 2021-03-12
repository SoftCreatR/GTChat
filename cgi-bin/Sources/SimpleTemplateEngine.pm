###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::SimpleTemplateEngine;
use strict;

bless({});

sub process
{
	my($data, $main, $output) = @_;

	foreach my $entry (@$data)
	{
		if (ref($entry))
		{
			$main->{template_vars}{template_line} = $entry->[1];
			if ($entry->[0])
			{
				$main->{modules}{$entry->[2]}{template_block_handlers}{$entry->[3]}->($entry->[2], $main, $entry->[6], $entry->[4], $entry->[5], $output);
			}
			else
			{
				$main->{modules}{$entry->[2]}{template_command_handlers}{$entry->[3]}->($entry->[2], $main, $entry->[4], $output);
			}
		}
		else
		{
			$$output .= $entry;
		}
	}
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	my $hashmodule = $main->{modules}{'sourcedir::joinedhash.pm'};
	my $blocks = $hashmodule->new($main->{definitions}{template_blocks}, $main->{settings}{custom_template_blocks});
	my $commands = $hashmodule->new($main->{definitions}{template_commands}, $main->{settings}{custom_template_commands});

	my @stack = ();

	my $data = [];

	my $block_switched;
	my $block_tag;
	my $block_switchtag;
	my $block_endtag;
	my $block_handler;
	my $block_start;
	my $block_params;

	local $/;
	my @pairs = (<$file> =~ m/(.*?)(?:\{([^\n}]+)\}|$)/sg);
	my $line = $.;
	for (my $i=0;$i<=$#pairs;$i+=2)
	{
		if ($pairs[$i] ne "")
		{
			if ($#$data<0 || ref($data->[-1]))
			{
				push @$data, $pairs[$i];
			}
			else
			{
				$data->[-1] .= $pairs[$i];
			}
			$line += $pairs[$i] =~ tr/\n//;
		}

		if (defined($pairs[$i+1]))
		{
			my @params = split(/\|/,$pairs[$i+1]);
			my $tag = $params[0];

			if (!defined($block_switched) && defined($block_switchtag) && $tag eq $block_switchtag)
			{
				$block_switched = $data;
				$data = [];
			}
			elsif (defined($block_endtag) && $tag eq $block_endtag)
			{
				my $data2;
				if (defined($block_switched))
				{
					$data2= bless($data);
					$data = $block_switched;
				}

				my @array = (1,$block_start,$block_handler,$block_tag,bless($data),$data2,$block_params);
				($data,$block_switched,$block_tag,$block_switchtag,$block_endtag,$block_handler,$block_start,$block_params)=@{pop @stack};
				push @$data, \@array;
			}
			else
			{
				if (exists($blocks->{$tag}))
				{
					push @stack,[$data,$block_switched,$block_tag,$block_switchtag,$block_endtag,$block_handler,$block_start,$block_params];

					$block_tag = $tag;
					$block_handler = $blocks->{$tag};
					my $handler = $main->{modules}{$block_handler};
					$main->fatal_error('taghandler_notfound',{tag => $tag, file => $handler->{filename}}) unless (exists($handler->{template_block_handlers}{$tag}));

					$data = [];
					$block_switched = undef;
					$block_switchtag = $handler->{block_switch_tags}{$tag};
					$block_endtag = defined($handler->{block_end_tags}{$tag}) ? $handler->{block_end_tags}{$tag} : 'ENDBLOCK';
					$block_start = $line;
					$block_params = \@params;
				}
				elsif (exists($commands->{$tag}))
				{
					my $handler = $main->{modules}{$commands->{$tag}};
					$main->fatal_error('taghandler_notfound',{tag => $tag, file => $handler->{filename}}) unless (exists($handler->{template_command_handlers}{$tag}));
					push @$data, [0,$line,$commands->{$tag},$tag,\@params];
				}
				else
				{
					$main->fatal_error('tag_unknown',{template => $main->{template_vars}{template_name}, line => $line, tag => $tag});
				}
			}
		}
	}
	$main->fatal_error('endblock_missing',{template => $main->{template_vars}{template_name}, line => $block_start, tag => $block_tag, endtag => $block_endtag}) if ($#stack>=0);

	return bless($data);
}
