(
func: {|node|

    var view = View()
    .layout_(VLayout()
        .margins_(1)
        .spacing_(1)
    );

    var swap, moveUp, moveDown, updateButtons, fxwatcher;
    var fxbuttonsview = View().layout_(VLayout().margins_(1).spacing_(1));
    //var fxnode = if (node.respondsTo(\node)) { node.node }{ node };
    var fxnode = node.tryPerform(\node) ?? { node };
    var fxmenu = UiModule('fxmenu');
    //var presetview = UiModule('presets');

    swap = {|node, index2, index1|

        var fx1 = node.inserts[index1];
        var fx2 = node.inserts[index2];

        var obj1 = node.objects[index1];
        var obj2 = node.objects[index2];

        var synth1 = Synth.basicNew(obj1.synthDef.name, Server.default, obj1.nodeID);
        var synth2 = Synth.basicNew(obj2.synthDef.name, Server.default, obj2.nodeID);

        synth2.moveBefore(synth1);

        node.objects[index1] = obj2;
        node.objects[index2] = obj1;

        node.inserts[index1] = fx2;
        node.inserts[index2] = fx1;

        node.changed(\reorder)
    };

    moveUp = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num-1];

        if (index2.notNil) {
            swap.(fxnode, index, index2);
        } {
            "can't move node".warn;
        }
    };

    moveDown = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num+1];

        if (index2.notNil) {
            swap.(fxnode, index2, index);
        } {
            "can't move node".warn;
        }
    };

    updateButtons = {

        var ctrls = fxnode.inserts;

        fxbuttonsview.children.do({|child|
            child.remove
        });

        if (ctrls.indices.size > 0) {

            ctrls.doRange({|obj, index, i|

                fxbuttonsview.layout.add(
                    HLayout(

                        StaticText()
                        .string_(obj.name.asString.split($.)[0].toUpper)
                        .stringColor_(Color.white.alpha_(0.5))
                        .mouseDownAction_({|ctrl, x, y, mod, num, count|

                            if (obj.type == 'vst') {
                                switch (mod,
                                    262144, { // ctrl key
                                        UiModule('instr').gui(fxnode, index)
                                    },
                                    524288, { // alt key
                                        obj['ctrl'].gui
                                    },
                                    {
                                        obj['ctrl'].editor
                                    }
                                )
                            }{
                                var ctrl = obj['ctrl'];
                                if (ctrl.view.notNil) {
                                    var key = 'ui/' ++ ctrl.view;
                                    if (Module.exists(key)) {
                                        var fxview = UiModule(ctrl.view).view(fxnode, index);
                                        fxview.bounds = Rect(view.bounds.left, view.bounds.top);
                                        fxview.front;
                                    } {
                                        "custom view does not exists: %".format(key).warn;
                                        UiModule('instr').gui(fxnode, index)
                                    }
                                }{
                                    var left, top;
                                    var fxview = UiModule('instr').view(fxnode, index);
                                    var parents = view.getParents();
                                    var parent;
                                    var win;
                                    if (parents.notNil) {
                                        var width;
                                        parent = parents.last;
                                        width = parent.bounds.width;
                                        left = parent.bounds.left + width + 5;
                                        top = parent.bounds.top;
                                    };
                                    //fxview.bounds = Rect(left, top, 100, 200);
                                    fxview.front;
                                    //win = parent.findWindow;
                                    //if (win.notNil) {
                                    //    win.setTopLeftBounds(fxview.bounds.top_(top).left_(left), 0)
                                    //};

                                    //[left, top].postln;
                                    //parent.moveTo(0, top);
                                    //parent.bounds = Rect(left, top, 100, 200);
                                    //fxview.parent.setTopLeftBounds( Rect(left, top, 100, 200) )

                                }
                            }
                        }),

                        nil,

                        /*
                        Button().states_([  ["↓", nil, Color.clear]  ]).action_({
                            moveDown.(index);
                        })
                        .maxWidth_(20),
                        Button().states_([  ["↑", nil, Color.clear]  ]).action_({
                            moveUp.(index);
                        })
                        .maxWidth_(20),

                        Button().states_([  ["x", nil, Color.clear]  ]).action_({
                            node.fx(index, nil)
                        })
                        .maxWidth_(20)
                        //.icon_(Image.new(App.librarydir ++ "images/noun_Delete_1982479.png")),
                        */
                    ),
                    stretch: 1
                );
            });
            fxbuttonsview.layout.add(UserView(), stretch:10)
        };
    };

    updateButtons.();

    fxwatcher = {|obj, what|
        if (what == \source or: {what == \reorder}) {
            // there is a lag between when the source
            // gets added and the node is ready on the
            // server
            var wait = if (what == \reorder) {0.1}{1};
            {
                updateButtons.();
            }.defer(wait)
        }
    };

    fxnode.addDependant(fxwatcher);
    //view.layout.add( fxmenu.view(fxnode).resize_(1) );
    view.layout.add( fxbuttonsview.resize_(1));
    view.layout.add( nil );
    //view.layout.add( presetview.view(fxnode) );
    //view.layout.add( nil);
    view
    .background_(Color.clear)
    .resize_(1)
    .onClose_({
        fxnode.removeDependant(fxwatcher);
    });

}
)
