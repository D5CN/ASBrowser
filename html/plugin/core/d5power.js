/* GET变量 */
    var GET = {};
    var url = window.location.href.split('#')[0];
    var arr = url.split('?')[1];
    var school_name;
    var cookie_domain;
    var school_conf;
    var DEBUG = true;



    arr && (arr = arr.split('&'));
    for (var i = 0, j = (arr ? arr.length : 0); i < j; i++) {
      var src = arr[i];
      if (!src || src == '') continue;
      var idx = src.indexOf('=');
      if (idx != -1) GET[src.substr(0, idx)] = src.substr(idx + 1);
    }
/* 服务器配置 */

    const SERVER_AI = 'http://ai.qjxxpt.com/core_dev/info.php';
    const SERVER_AI_CORE = 'http://ai.qjxxpt.com/core_dev/index.php';
    const SERVER_EXAM = 'http://ai.qjxxpt.com/';
    const LOGIN_API = 'http://ai.qjxxpt.com/interface/wxbind/index.html?loginmode=m&jump_to=http://school.qjxxpt.com/gaokao/index_center.html';
    const NOW_AD = 'http://school.qjxxpt.com/gaokao/ad/20-04-orange/index.html';
    const SERVER_ROOT = 'http://school.qjxxpt.com/';
    const COOKIE_NAME_UID = 'school_qjxxpt_uid';

/** 运行环境 */
/*
    var APP_MODE = null;
    if(GET.driver)
    {
        APP_MODE = GET.driver;
        cookie.set('app_qjxxpt_driver',GET.driver);
    }else{
        APP_MODE = cookie.get('app_qjxxpt_driver');
    }
*/

var $iosActionsheet = $('#iosActionsheet');
var $iosMask = $('#iosMask');
var $iosActionSubmit = $('#btn_actionsheep_submit')

function ASHide() {
    $iosActionsheet.removeClass('weui-actionsheet_toggle');
    $iosMask.fadeOut(200);
}

function isMobile()
{
    //平台、设备和操作系统 
    var system = { 
        win: false, 
        mac: false, 
        xll: false, 
        ipad:false,
        iphone:false
    }; 
    //检测平台 
    var p = navigator.platform;
    system.win = p.indexOf("Win") == 0 ? true : false; 
    system.mac = p.indexOf("Mac") == 0 ? true : false; 
    system.x11 = (p == "X11") || (p.indexOf("Linux") == 0) ? true : false; 
    system.ipad = (navigator.userAgent.match(/iPad/i) != null)?true:false;
    system.iphone = (navigator.userAgent.match(/iPhone/i != null)) ? true : false;

    var isMobile = true;
    //跳转语句，如果是手机访问就自动跳转到wap.baidu.com页面 
    if (system.win || system.mac || system.x11) { 
        //  something.... 
        isMobile = false;
    }

    return {mobile:isMobile,system:''}
}

function ASDisplay(title,content,callback,callbackname)
{
    if(!$iosActionsheet || !$iosMask)
    {
        alert('页面中尚未写入ActionSheet功能');
        return;
    }
    $('#as_title').html(title);
    $('#as_content').html(content);

    $iosMask.on('click', ASHide);
    $('#iosActionsheetCancel').on('click', ASHide);
    $iosActionsheet.addClass('weui-actionsheet_toggle');
    $iosMask.fadeIn(200);

    if(callback!=null)
    {
        $iosActionSubmit.css('display','block');
        $iosActionSubmit.on('click',callback);
        if(callbackname) $iosActionSubmit.html(callbackname);
    }else{
        $iosActionSubmit.css('display','none');
    }
}

function base64Encode(input)
{
var rv;
rv = encodeURIComponent(input);
rv = unescape(rv);
rv = window.btoa(rv);
return rv;
}

function base64Decode(input){
    rv = window.atob(input);
    rv = escape(rv);
    rv = decodeURIComponent(rv);
    return rv;
}

function formatSecond(s)
{
    var m = Math.floor(s/60);
    if(m>90) m = 90;
    var s = s%60;

    if(m<10) m = '0'+m;
    if(s<10) s = '0'+s;
    return m+':'+s;
}

function d5request(cmd,data,callback,server='',interface_id=10)
{
    server = server=='' ? 'http://cloud.tz2.qjxxpt.com/clsc/User/index.php' : server;
    if(server.indexOf('?')==-1)
    {
        server += '?type='+interface_id+'&do='+cmd;
    }else{
        server += '&type='+interface_id+'&do='+cmd;
    }
    
    if(DEBUG)
    {
        for(var k in data)
        {
            server+='&'+k+'='+data[k];
        }
        console.log(server);
    }
    
    //console.log("[D5Request]"+cmd.toString(16)+'@'+server+'\n'+JSON.stringify(data));
    $.post(server, data, function(src){
        //console.log("[D5Request] request:"+src);
        try{
            
            // process response
            var obj = JSON.parse(src)
            callback(obj);
        }catch(err){
            console.log("[Err]"+err.message+"\n"+err.stack);
            var obj = {cmd:-99,data:{err:err.message,src:src}}
            callback(obj);
        }
        
    })
}

function d5parse(data,temp)
{
    for(var k in data)
    {
        if(k=='0' || k>0) continue;
        temp = temp.replace(new RegExp("\{\{"+k+"\}\}","ig"),data[k]);
    }
    return temp;
}

function insert_record(uid,pusher,type=0)
{
    d5request('b04',{uid:uid,pusher:pusher,type_from:type},function(res){
        if(res.code == 1){

        }
    },'',11);
}