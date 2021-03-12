if (typeof(document.body) == 'undefined' && typeof(document.getElementsByTagName) != 'undefined')   // NN 6.x hack
{
	document.body = document.getElementsByTagName('body')[0];
}

if (typeof(document.getElementById) == 'undefined' && typeof(document.all) != 'undefined')          // IE 4.0 hack
{
	document.getElementById = function(id)
	{
		return document.all[id];
	}
}

if (typeof([].push) == 'undefined')     // IE 5.0 hack
{
	Array.prototype.push = function(value)
	{
		this[this.length] = value;
	}
}

if (typeof([].splice) == 'undefined')   // IE 5.0 hack
{
	Array.prototype.splice = function(i, k)
	{
		for (var z=i; z<this.length-k; z++)
			this[z] = this[z+k];
		this.length = this.length - k;
	}
}

// Opens a chat template in a new window with given size
// Needs the variable cgi either in the current frame or it's parent
function openWindow(template, width, height)
{
	return openCenteredWindow(cgi + ';template=' + template, template.replace(/[^a-zA-Z0-9]/g,''), width, height);
}

// Opens a new window centered on the screen
function openCenteredWindow(url, name, width, height)
{
	var wnd;
	try
	{
		var left = (screen.availWidth-width)/2;
		var top = (screen.availHeight-height)/2;
		wnd = window.open(url, name, 'resizable=yes,scrollbars=yes,width='+width+',height='+height+',outerWidth='+width+',outerHeight='+height+',left='+left+',top='+top);
		wnd.focus();
	}
	catch (e) {}

	return wnd;
}

// Changes the size of the window to the content's size
// IE 4+, Netscape 6+
function autosize(frame)
{
	if (typeof(frame) == 'undefined')
		frame = window;

	if (typeof(frame.autosize) == 'undefined')
		frame.autosize = autosize;

	var current = 0;
	if (typeof(frame.innerHeight) != 'undefined')                       // Netscape and Mozilla
		current = frame.innerHeight;
	else if (typeof(frame.document.body.clientHeight) != 'undefined')
		current = frame.document.body.clientHeight;                     // IE 4+ and Opera 7+

	var needed = 0;
	if (typeof(frame.getComputedStyle) != 'undefined')                  // Netscape 6.1+, Mozilla and Opera 7.20+
	{                                                 
		var style = frame.getComputedStyle(frame.document.body, '');
		needed = parseInt(style.getPropertyValue('margin-top')) + parseInt(style.getPropertyValue('height')) + parseInt(style.getPropertyValue('margin-bottom')) + 1;
	}
	else if (typeof(frame.document.body.scrollHeight) != 'undefined')   // IE 5+ and Opera 7+
		needed = frame.document.body.scrollHeight;

	// the window content has to be at least 150 pixel high
	if (needed > 0 && needed < 150)
		needed = 150;

	if (current > 0 && needed > 0)
	{
		var changeBy = needed - current;

		var wndHeight = 0;
		if (typeof(frame.top.outerHeight) != 'undefined')
			wndHeight = frame.top.outerHeight;
		else
			wndHeight = current + 50;

		if (wndHeight + changeBy > screen.availHeight - 50)
			changeBy = screen.availHeight - 50 - wndHeight;
				
		frame.top.moveBy(0, -changeBy/2);
		frame.top.resizeBy(0, changeBy);
	}
}

function checkMain()
{
	if (typeof(window.main) != 'undefined')
	{
		if (window.main && window.main.closed)
			window.main = false;

		return;
	}

	var frame = window;
	while (typeof(frame.opener) != 'undefined' && frame.opener && !frame.opener.closed)
	{
		frame = frame.opener;
		while (typeof(frame.main) == 'undefined' && typeof(frame.parent) != 'undefined' && frame.parent && frame.parent != frame)
			frame = frame.parent;
	}

	if (typeof(frame.main) != 'undefined')
		window.main = frame.main;
	else
		window.main = false;
}
