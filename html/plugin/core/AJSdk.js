    const isAndroidWebView = /Android/.test(navigator.userAgent);
    const isChromium = !isAndroidWebView && navigator.vendor === "Google Inc.";
    const isEdge = /Edge/.test(navigator.userAgent);
    const isWebKit = !isAndroidWebView && !isChromium && !isEdge;
    const aj_callback_list = {};
    var aj_callback_index = 0;
    var aj_installed = false;

    function AJCallBack(index,data)
    {
        var fun = aj_callback_list['_'+index];
        if(fun)
        {
            fun(data);
        }
    }

    function AJtrace(msg)
    {
        console.log("[AJTrace] "+msg);
    }

    function AJInstall(callback)
    {
        if(aj_installed)
        {
            callback.apply();
            return;
        }

        if (isChromium) {
            // Important: CefSharp binding must now be performed async
            (async () => {
                await window.CefSharp.BindObjectAsync("webViewANE", "bound").then((res) => {
                    if (res.Success) {
                        aj_installed = true;
                        callback.apply();
                    }
                });
            })();
        } else {
            aj_installed = true;
            callback.apply();
        }
    }

    function AJCall(command,callback,...params)
    {
        !params && (params=[]);
        params.unshift(command);
        if(callback!=null)
        {
            aj_callback_list['_' + aj_callback_index] = callback;
            params.unshift(aj_callback_index)
            aj_callback_index++;
        }else{
            params.unshift(-1);
        }

        const messageToPost = {
            'functionName': 'callAs',
            'callbackName': callback ? 'AJCallBack' : null,
            'args': params
        };

        if (isChromium) {
            webViewANE.postMessage(messageToPost);
        } else if (isAndroidWebView) {
            webViewANE.postMessage(JSON.stringify(messageToPost));
        } else if (isEdge) {
            window.external.notify(JSON.stringify(messageToPost));
        } else {
            window.webkit.messageHandlers.webViewANE.postMessage(messageToPost);
        }
    }