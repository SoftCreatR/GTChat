###################################################################
#  GTChat GTChat 0.95 Alpha Build 20040120 core file              #
#  Copyright 2001-2006 by Wladimir Palant (http://www.gtchat.de)  #
#  Copyright 2006 by Sascha Heldt (https://www.gt-chat.de)        #
###################################################################

package GT_Chat::SimpleTemplateEnginePerl;
use strict;

bless({});

sub process
{
	my($data, $main, $output) = @_;

	$data->[0]->($main, $output, $data->[1], $data->[2]);
}

sub parseTemplate
{
	my($self, $main, $file) = @_;

	my $hashmodule = $main->{modules}{'sourcedir::joinedhash.pm'};
	my $blocks = $hashmodule->new($main->{definitions}{template_blocks}, $main->{settings}{custom_template_blocks});
	my $commands = $hashmodule->new($main->{definitions}{template_commands}, $main->{settings}{custom_template_commands});

	my @block_stack = ();
	my @switch_stack = ();
	my @end_stack = ();
	my @switched_stack = ();
	my @line_stack = ();

	my $modules = [];
	my $handlers = [];
	my $handler_pos = {};

	local $/;
	my $input = <$file>;
	my $sub = '';
	my $line = $.;
	while ($input =~ m/(.*?)(?:\{([^\n\}]+)\}|$)/sg)
	{
		my $text = $1;
		my $command = $2;

		if (defined($text) && $text ne '')
		{
			$line += $text =~ tr/\n//;
			$text =~ s/([\\'])/\\$1/sg;
			$sub .= '$$output.=\''.$text.'\';';
		}

		if (defined($command) && $command ne '')
		{
			my @params = split(/\|/,$command);
			my $tag = $params[0];

			if (defined($switch_stack[-1]) && $switch_stack[-1] eq $tag)
			{
				$switch_stack[-1] = undef;
				$switched_stack[-1] = 1;
				$sub .= '}]),bless([sub{my($main,$output)=@_;';
			}
			elsif (defined($end_stack[-1]) && $end_stack[-1] eq $tag)
			{
				my $switched = $switched_stack[-1] ? '' : ',undef';
				pop @block_stack;
				pop @switch_stack;
				pop @switched_stack;
				pop @end_stack;
				pop @line_stack;
				$sub .= "}])$switched,\$output);";
			}
			else
			{
				my $tag_escaped = $tag;
				$tag_escaped =~ s/([\\'])/\\$1/g;

				foreach my $param (@params)
				{
					$param =~ s/([\\'])/\\$1/g;
					$param = "'$param'";
				}
				my $params = join(',',@params);

				if (exists($blocks->{$tag}))
				{
					my $handler = $main->{modules}{$blocks->{$tag}};

					my $pos;
					if (exists($handler_pos->{$blocks->{$tag},1,$tag}))
					{
						$pos = $handler_pos->{$blocks->{$tag},1,$tag};
					}
					else
					{
						$main->fatal_error('taghandler_notfound',{tag => $tag, file => $handler->{filename}}) unless (exists($handler->{template_block_handlers}{$tag}));

						push @$modules, $handler;
						push @$handlers, $handler->{template_block_handlers}{$tag};
						$pos = $handler_pos->{$blocks->{$tag},1,$tag} = $#$handlers;
					}

					push @block_stack, $tag;
					push @switch_stack, $handler->{block_switch_tags}{$tag};
					push @switched_stack, 0;
					push @end_stack, defined($handler->{block_end_tags}{$tag}) ? $handler->{block_end_tags}{$tag} : 'ENDBLOCK';
					push @line_stack, $line;

					$sub .= "\$handlers->[$pos](\$modules->[$pos],\$main,[$params],bless([sub{my(\$main,\$output)=\@_;";
				}
				elsif (exists($commands->{$tag}))
				{
					my $handler = $main->{modules}{$commands->{$tag}};

					my $pos;
					if (exists($handler_pos->{$commands->{$tag},0,$tag}))
					{
						$pos = $handler_pos->{$commands->{$tag},0,$tag};
					}
					else
					{
						$main->fatal_error('taghandler_notfound',{tag => $tag, file => $handler->{filename}}) unless (exists($handler->{template_command_handlers}{$tag}));

						push @$modules, $handler;
						push @$handlers, $handler->{template_command_handlers}{$tag};
						$pos = $handler_pos->{$commands->{$tag},0,$tag} = $#$handlers;
					}

					$sub .= "\$handlers->[$pos](\$modules->[$pos],\$main,[$params],\$output);";
				}
				else
				{
					$main->fatal_error('tag_unknown',{template => $main->{template_vars}{template_name}, line => $line, tag => $tag});
				}
			}
		}
	}
	$sub = 'sub{my($main,$output,$modules,$handlers)=@_;'.$sub.'}';

	$main->fatal_error('endblock_missing',{template => $main->{template_vars}{template_name}, line => $line_stack[-1], tag => $block_stack[-1], endtag => $end_stack[-1]}) if ($#block_stack>=0);

#    print "Content-Type: text/html\n\n$sub";

	my $compiled = eval($sub);
	die $@ if $@;
	return bless([$compiled,$modules,$handlers]);
}
