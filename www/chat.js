roomlistdelay = 10000;
scrolldelay = 150;
aliveinterval = 50000;
refreshdelay = 6000;
logoutpage = "";
autokick = 0;
send_blocking_timeout = 15000;

flooding_maxnum = 5;
flooding_interval = 5000;
flooding_warnings = 1;
flooding_expireinterval = 600000;

function showReminder()
{
	hwnd=window.open(cgi+"&action=reminder","reminder","resizable=yes,bars=yes,width=430,height=200");
}

function setLocation(location,link)
{
	location.replace(link);
}

function doLogin()
{
	parent.data.document.form.mustLogout.value=0;
	if (logoutpage == "")
		setLocation(parent.location,cgi.split("?")[0]);
	else
		setLocation(parent.location,logoutpage);
}
function doSend() {
	text=parent.input.document.inputForm.text.value;
	parent.input.document.inputForm.text.value = "";
	sendText(text);
	parent.input.document.inputForm.text.focus();
	checkFlooding();
	return false;
}
function addText(text)
{
	parent.input.document.inputForm.text.value += " "+text;
	parent.input.document.inputForm.text.focus();
}
function insertText(text)
{
	if (parent.input.document.inputForm.text.value.replace(/^\s*/,"").substr(0,1)!='/')
		parent.input.document.inputForm.text.value = text+parent.input.document.inputForm.text.value;
	parent.input.document.inputForm.text.focus();
}

function setSendAllowed(allow,frame)
{
	if (parent.data.document.form.canSend.value==allow)
		return;

	parent.data.document.form.canSend.value=allow;
	if (allow==0)
		parent.data.document.form.timeout.value=parent.data.setTimeout("setSendAllowed(1,self)",send_blocking_timeout);
	else
		parent.data.clearTimeout(parent.data.document.form.timeout.value*1);

	if (allow!=0 && parent.data.document.form.buffer.value!="")
		sendText("");
}

function getSendAllowed(frame)
{
	return parent.data.document.form.canSend.value;
}

function sendText(text,frame)
{
	if (parent.input && parent.input.document && parent.input.document.sendForm)
	{
		parent.data.document.form.buffer.value+=text+'\x01';
		if (text!="/alive")
			parent.data.document.form.lastactive.value=(new Date()).getTime();
	
		if (getSendAllowed(frame)!=0)
		{
			setSendAllowed(0,frame);
			parent.input.document.sendForm.text.value=parent.data.document.form.buffer.value;
			parent.data.document.form.buffer.value="";
			parent.input.document.sendForm.submit();
		}
	}
}

function updateMessages(mode)
{
	setLocation(parent.messages.location,cgi+"&action=receive&dhtml="+mode);
}
function updateUserList()
{
	setLocation(parent.users.location,cgi+"&action=userlist");
}
function updateInput()
{
	setLocation(parent.input.location,cgi+"&action=inputframe");
}
function updateOptions()
{
	setLocation(parent.options.location,cgi+"&action=optionsframe");
}
function updateRoomList()
{
	setLocation(parent.rooms.location,cgi+"&action=roomlist");
}
function updateRoomList2()
{
	setTimeout("updateRoomList()",roomlistdelay);
}
function viewProfile(user)
{
	hwnd=window.open(cgi+"&action=viewprofile&username="+user,user.substr(1),"resizable=yes,scrollbars=yes,width=430,height=480");
}
function editProfile(user)
{
	hwnd=window.open(cgi+"&action=modifyprofile&username="+user,user.substr(1),"resizable=yes,scrollbars=yes,width=430,height=480");
}
function viewRooms()
{
	hwnd=window.open(cgi+"&action=viewrooms","roomlist","resizable=yes,scrollbars=yes,width=600,height=450");
}
function showUsers()
{
	hwnd=window.open(cgi+"&action=searchuser","allusers","resizable=yes,scrollbars=yes,width=430,height=480");
}
function showAllUsers()
{
	hwnd=window.open(cgi+"&action=allusers","allusers","resizable=yes,scrollbars=yes,width=430,height=480");
}
function addToBanList(host,ip,forwardedfor)
{
	hwnd=window.open(cgi+"&action=modifybanlist&domain="+host+"&ip="+ip+"&forwardedfor="+forwardedfor,"admin","resizable=yes,scrollbars=yes,width=600,height=450");
}
function viewAdmin()
{
	hwnd=window.open(cgi+"&action=admin","admin","resizable=yes,scrollbars=yes,width=600,height=450");
}
function testcol(color)
{
	if (color.length!=6)
		return false;
	for (i=0;i<color.length;i++)
	{
		if ((color.charAt(i)<"0" || color.charAt(i)>"9") && (color.charAt(i)<"a" || color.charAt(i)>"f") && (color.charAt(i)<"A" || color.charAt(i)>"F"))
			return false;
	}
	return true;
}

function toInt(h)
{
	mask="0123456789abcdef";
	h=h.toLowerCase();
	return mask.indexOf(h.charAt(0))*16+mask.indexOf(h.charAt(1));
}

function toHex(i)
{
	mask="0123456789abcdef";
	if (i>255)
		i=255;
	if (i<0)
		i=0;
	return mask.charAt(i/16)+mask.charAt(i%16);
}

function selcol(color)
{
	if (color.charAt(0)=="#")
		color=color.substr(1);
	if (testcol(color))
	{
		if (document.form.color.style)
			document.form.color.style.color=color;
		else if (document.layer)
			document.layer.bgColor=color;
		document.form.red.value = toInt(color.substr(0,2));
		document.form.green.value = toInt(color.substr(2,2));
		document.form.blue.value = toInt(color.substr(4,2));
		color="#"+color;
	}
	else
	{
		if (document.form.color.style)
			document.form.color.style.color="black";
		else if (document.layer)
			document.layer.bgColor="black";
		document.form.red.value = "";
		document.form.green.value = "";
		document.form.blue.value = "";
	}
	document.form.color.value = color;
}



function combineColors()
{
	selcol(toHex(document.form.red.value)+toHex(document.form.green.value)+toHex(document.form.blue.value));
}

function msgOutput(msg)
{
	lines=msg.split("\n");
	for (i=0;i<lines.length;i++)
	{
		if (lines[i].substr(0,8)=="<script>" && lines[i].substr(lines[i].length-9,9)=="</script>")
		{
			lines[i]=lines[i].substr(8,lines[i].length-17);
			setTimeout(lines[i],0);
		}
		else
		{
			if (parent.messages.document.all && parent.messages.document.all.dtext)
				parent.messages.document.all.dtext.innerHTML += lines[i]+'\n';
			else
				parent.messages.document.writeln(lines[i]);
		}
	}
	doScroll();
}

function doScroll(frame)
{
	if (parent.data.document.form.scroll.value!=0 && parent.messages)
	{
		parent.messages.scroll(1,5000000);
		if (parent.messages.document.ftext)
			parent.messages.document.ftext.scroll(1,5000000);
	}
}

function checkFlooding()
{
	form=parent.data.document.form;
	now=(new Date()).getTime();
	
	if (flooding_maxnum<=0 || flooding_interval<=0)
		return;

	value=form.lasttimes.value;

	lasttime="";
	newvalue="";
	for (i=0;i<flooding_maxnum;i++)
	{
		if (value.lastIndexOf(" ")>=0)
		{
			if (i==flooding_maxnum-1)
				lasttime=value.substring(value.lastIndexOf(" ")+1,value.length);
			else
				newvalue=" "+value.substring(value.lastIndexOf(" ")+1,value.length)+newvalue;
			value=value.substring(0,value.lastIndexOf(" "));
		}
	}
	newvalue+=" "+now;
	form.lasttimes.value=newvalue;

	if (lasttime!="" && now-lasttime<flooding_interval)
	{
		if (flooding_expireinterval > 0 && now-form.lastwarning.value > flooding_expireinterval)
			form.numwarnings.value = 0;
		form.numwarnings.value++;
		form.lastwarning.value=now;
		if (form.numwarnings.value > flooding_warnings)
			sendText('/quit');
		else
			alert(form.warntext.value);
		form.lasttimes.value="";
	}
}
