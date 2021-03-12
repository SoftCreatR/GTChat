function resetScrollPos()
{
	if (typeof(document.body.scrollTop) != 'undefined')
		parent.oldScrollTop = document.body.scrollTop;

	if (typeof(window.pageYOffset) != 'undefined')
		parent.oldYOffset = window.pageYOffset;

	if (typeof(document.body.clientHeight) != 'undefined')
	{
		parent.oldHeight = document.body.clientHeight;
	}
	else if (typeof(window.innerHeight) != 'undefined')
	{
		parent.oldHeight = window.innerHeight;
	}
}

function initPush()
{
	setInterval('doScroll()', 150);

	if (parent.restore != '')
	{
		var html = '';
		try
		{
			html = parent.restore.replace(/<script[^>]*>.*?<\/script>/i, '');
		}
		catch(e)        // IE 5.0 hack
		{
			var lines = parent.restore.split("\n");
			var isScript = false;
			for (var i=0;i<lines.length;i++)
			{
				if (!isScript && lines[i].match(/<script[^>]*>/i))
					isScript = true;
				else if (isScript && lines[i].match(/<\/script>/i))
					isScript = false;
				else if (!isScript)
					html += lines[i]+'\n';
			}
		}
		document.writeln(html);
	}

	if (typeof(parent.restoreWindow) != 'undefined' && !parent.restoreWindow.closed)
		parent.restoreWindow.close();

	document.onreadystatechange = function ()
	{
		if (document.readyState == "complete")
			reconnect();
	}
	
	window.onload = reconnect;
}

function doScroll()
{
	var tolerance = 0;
	var yoffset = 0;
	var scrolltop = 0;

	if (typeof(document.body.scrollTop) != 'undefined')
		scrolltop = document.body.scrollTop;

	if (typeof(window.pageYOffset) != 'undefined')
		yoffset = window.pageYOffset;
	
	if (typeof(document.body.clientHeight) != 'undefined')
	{
		if (parent.oldHeight)
			tolerance = Math.abs(parent.oldHeight - document.body.clientHeight);
		parent.oldHeight = document.body.clientHeight;
	}
	else if (typeof(window.messages.innerHeight) != 'undefined')
	{
		if (parent.oldHeight)
			tolerance = Math.abs(parent.oldHeight - window.innerHeight);
		parent.oldHeight = window.innerHeight;
	}

	if (!(yoffset+tolerance < parent.oldYOffset || scrolltop + tolerance < parent.oldScrollTop))
	{
		scrollBy(0,50000);
		parent.oldYOffset = yoffset;
		parent.oldScrollTop = scrolltop;
	}
}

function reconnect()
{
	if (!parent.exiting)
	{
		parent.exiting = 1;
		parent.restoreWindow = parent.openWindow('message;message=info_disconnect;image=error;id=',480,200);

		parent.restore += getMessages(true);

		parent.log += getMessages();

		document.location.href = parent.cgi + ';action=messages';
	}
}

function getMessages(clear)
{
	var ret = document.body.innerHTML;
	if (ret.indexOf('GT-Chat -->') >= 0)
		ret = ret.substr(ret.indexOf('GT-Chat -->')+19);
	else
	{                   // Opera hack
		ret = ret.replace(/.*<body[^>]*>/i,'');
		ret = ret.replace(/.*<\/script>/i,'');
		ret = ret.replace(/<hr[^>]*>.*/i,'');

		if (typeof(clear) != 'undefined')
			parent.restore = '';
	}

	return ret;
}
