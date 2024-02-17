
/*
(
w = Window("test", Rect(800, 200, 500, 400)).front;
w.layout = VLayout(
	nil,
	StaticText().align_(\center).string_("hello"),
	nil
);

w.view  // a TopView btw
.onResize_({ |view|
	view.findWindow.bounds.debug("resized")
})
.onMove_({ |view|
	view.findWindow.bounds.debug("moved")
});
)
*/

(
func: {|node, index, cmds|

    var cmdhistory = List.new;
    var currentindex = 0;
    var currentcmd;
    var fxnode = node.node;
    var windowname = if (index.notNil) {
        "%/%".format(node.key, fxnode.fxchain[index].name);
    }{
        node.key
    };
    var view, target, scope;
    var getView, views=[];
    var parse, loadViews;
    var shortcuts = (
        $1: "props",
        $2: "fx",
        $3: "freq",
        $4: "scope",
        $5: "kb",
        $6: "meter"
    );

    if (index.isNil) {
        var fx = UiModule('fx').view(node);
        var presets = UiModule('presets').view(node);
        var freq = UiModule('freq').view(node).maxHeight_(80);
        views = [presets, freq, fx]
    } {
        var props = UiModule('props').view(node, index).minWidth_(200);
        views = [props]
    };

    target = View().layout_(VLayout(*views).margins_(0).spacing_(0));//.resize_(1);

    parse = {|str|

        var exec, match;
        var getNextToken;
        var hasMoreTokens;
        var spec;
        var cursor = 0;

        // as pairs
        spec = [
            'string', "^[a-zA-Z0-9\/]+",
            '[', "^\\[",
            ']', "^\\]",
            '(', "^\\(",
            ')', "^\\)",
            nil, "^\\s+",
            nil, "^\,",

        ];

        hasMoreTokens = {
            cursor < str.size;
        };

        match = {|regex, str|
            var val = nil;
            var m = str.findRegexp(regex);
            if (m.size > 0) {
                val = m[0][1];
                cursor = cursor + val.size;
            };
            val;
        };

        getNextToken = {
            var getNext;
            var result = nil;
            getNext = {

                if (hasMoreTokens.()) {
                    spec.pairsDo({|k, v|
                        if (result.isNil) {
                            var val = match.(v, str[cursor..]);
                            //[k, v, val].debug("match");
                            if (val.notNil) {
                                if (k.isNil) {
                                    getNext.()
                                }{
                                    result = (
                                        type: k,
                                        val: val
                                    );
                                }
                            }
                        }
                    });
                };
            };

            getNext.();

            if (result.isNil) {
                "unexpected token %".format(str[cursor]).throw
            };

            result;
        };

        exec = {|list|

            var exit = false;

            while ({ hasMoreTokens.() and: { exit.not } }, {
                var token = getNextToken.();

                //token.debug("token");
                switch(token['type'],
                    // entities
                    'string', {
                        var ui = token['val'];
                        ui = ui.asString.split($/);
                        //ui.debug("ui..................");
                        list.add( getView.(ui[0], ui[1]) )
                    },
                    // grouping delimiters
                    '[', {
                        var result;
                        result = exec.(HLayout().margins_(3).spacing_(3));
                        list.add(result);
                    },
                    ']', {
                        list.add(nil);
                        exit = true;
                    },
                    '(', {
                        var result;
                        result = exec.(VLayout());
                        list.add(result);
                    },
                    ')', {
                        list.add(nil);
                        exit = true
                    }
                );
            });

            list;
        };
        exec.(VLayout());
    };

    getView = {|currentcmd, args|
        UiModule(currentcmd).view(node, args)         
    };

    loadViews = {|cmd|
        var layout;
        target.children.do({|child|
            child.remove
        });

        layout = parse.(cmd.asString);
        target.layout.add( layout );
    };

    view = View(bounds:75@150)
    .name_(windowname)
    .layout_(VLayout(
        HLayout(
            target
        ).margins_(5).spacing_(5),

        HLayout(
            DragSource()
            .object_(node)
            .maxWidth_(17)
            .string_(">")
            .dragLabel_(node.key)
            ,

            TextField()
            .keyDownAction_({|ctrl, char, mod, unicode, keycode, key|

                // 16777235 up
                // 16777237

                if (keycode == 126) {
                    var cmd = cmdhistory.wrapAt(currentindex);
                    ctrl.value = cmd;
                    currentindex = (currentindex - 1).clip(0, cmdhistory.size);
                };

                if (keycode == 125) {
                    var cmd = cmdhistory.wrapAt(currentindex);
                    ctrl.value = cmd;
                    currentindex = (currentindex + 1).clip(0, cmdhistory.size);
                };

                if (keycode == 36) {
                    //[ctrl, char, mod, unicode, keycode, key].postln;
                    //var args = "[" ++ ctrl.value ++ "]";
                    // it seems we need asCompileString to handle symbols
                    // and then we need to do interpret twice since
                    // the first call returns a string when needs
                    // to be interpreted as an array.
                    //args = args.asCompileString.interpret.interpret;
                    //args.postln;
                    //node.set(*args)
                    var parts, lhs, rhs;
                    var val = ctrl.value.asSymbol;
                    var view;
                    currentcmd = val;

                    cmdhistory.add(currentcmd);
                    currentindex = cmdhistory.size -1;

                    switch (currentcmd,
                        \play, {
                            node.play
                        },
                        \stop, {
                            node.stop
                        },
                        \close, {
                            target.children.do({|child|
                                child.remove
                            });
                        },
                        {
                            var cmd = val.asString;
                            cmd.debug("cmd");

                            case(

                                {cmd.beginsWith("@")}, {
                                    var parts = cmd.split(Char.space);
                                    var lhs = parts[0];
                                    var rhs = parts[1..].join("");
                                    var lhsparts = lhs.split($.);
                                    var prop = lhsparts[1];
                                    if (rhs.isNil or: {rhs == ""}) {
                                        var val = node.get(prop.asSymbol);
                                        ctrl.value = "@.% %".format(prop, val);
                                    } {
                                        node.set(prop.asSymbol, rhs.interpret);
                                    }
                                },
                                {cmd.beginsWith("mute")}, {
                                    var fadetime = 1;
                                    var cmd = val.asString;
                                    parts = cmd.split(Char.space);
                                    lhs = parts[0];
                                    rhs = parts[1..].join("");
                                    if (rhs.notNil) {
                                        fadetime = rhs.asFloat;
                                    };
                                    fxnode.stop(fadeTime:fadetime.debug("fadetime"))
                                },
                                {cmd.beginsWith("unmute")}, {
                                    var fadetime = 1;
                                    var cmd = val.asString;
                                    parts = cmd.split(Char.space);
                                    lhs = parts[0];
                                    rhs = parts[1..].join("");
                                    if (rhs.notNil) {
                                        fadetime = rhs.asFloat;
                                    };
                                    fxnode.play(fadeTime:fadetime.debug("fadetime"))
                                },
                                {cmd.beginsWith("out")}, {
                                    var cmd = val.asString;
                                    parts = cmd.split(Char.space);
                                    lhs = parts[0];
                                    rhs = parts[1].stripWhiteSpace.asFloat;
                                    fxnode.out = rhs;
                                },
                                {cmd.beginsWith("vol")}, {
                                    var cmd = val.asString;
                                    parts = cmd.split(Char.space);
                                    lhs = parts[0];
                                    rhs = parts[1].stripWhiteSpace.asFloat;
                                    fxnode.vol = rhs;
                                },
                                {
                                    var parts;
                                    cmd = cmd.asString.stripWhiteSpace;
                                    if (cmd[0].isDecDigit) {
                                        var char = cmd[0];
                                        if (cmd.size == 1) {
                                            cmd = shortcuts[char];
                                            if (cmd.notNil) {
                                                loadViews.(cmd)
                                            }
                                        }{
                                            if ( cmd.contains(" ") ) {
                                                cmd = cmd[2..];
                                                shortcuts[char] = cmd;
                                            } {
                                                loadViews.(cmd);
                                            }
                                        }
                                    } {
                                        loadViews.(cmd);
                                    }
                                }
                            );
                        }
                    );
                }
            }).background_(Color.clear),
        )
    ).margins_(0).spacing_(0)
    ).background_(Color.black);

    if (cmds.notNil) {
        loadViews.(cmds.asString);
    };

    view
    .resize_(1)
    .canReceiveDragHandler_({|view|
        //TODO: validate
        var val = View.currentDrag.value;
        true;
    })
    .receiveDragHandler_({|view, x, y|
        var val = View.currentDrag.value;
        val.debug("rec")
    })
    .keyDownAction_({|ctrl, char, mod|
        //[ctrl, a, b, c].debug("instr keydown");
        var cmd = shortcuts[char];
        if (cmd.notNil) {
            loadViews.(cmd);
        } 
    });
}
)
