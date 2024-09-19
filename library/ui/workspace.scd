
(
var func = {
    var w;
    var view;
    var tracks, mainlayout, outerlayout;
    var transport, refresh;
    var listLayout = GridLayout().spacing_(2).margins_(2), listView = View().background_(Color.clear);
    var muteBtn, tempoBox, recBtn, serverGuiBtn, midiBtn, mediaBtn;
    var left = 20;

    w = Window("", bounds:Rect(top: Window.screenBounds.height-300, left: left, width:200, height:250), border: false);//.front;

    muteBtn = Button()
    .states_([ ["⨴", nil, Color.clear], ["⨵", Color.fromHexString("F28C28"), Color.clear] ])
    .action_({|ctrl| 
        if (ctrl.value == 1) { 
            Server.default.mute;
            //ctrl.icon = Image("/Users/david/projects/droptableuser/images/unmute.png")
        }{ 
            Server.default.unmute;
            //ctrl.icon = Image("/Users/david/projects/droptableuser/images/mute.png")
        } 
    })
    //.icon_(Image("/Users/david/projects/droptableuser/images/mute.png") )
    //.iconSize_(15)
    .font_(Font(size:20))
    .fixedSize_(20)
    .toolTip_("mute")
    ;

    tempoBox = HLayout( 
        NumberBox()
        .value_( 60/T.tempo.reciprocal )
        .background_(Color.clear)
        .fixedWidth_(40)
        .action_({|ctrl|
            T.tempo = ctrl.value/60    
        })
        .toolTip_("bpm")
    );

    recBtn = Button().states_([ ["⏺", Color.red.alpha_(0.5), Color.clear], [ "⏹", Color.red.alpha_(0.5), Color.clear ] ])
    .action_({|ctrl| if (ctrl.value == 1) { T.daw.goToEnd.record }{ T.daw.stopRecording} })
    .font_(Font(size:20))
    .fixedSize_(20)
    .toolTip_("record")
    ;

    midiBtn = Button().states_([ ["⟚", nil, Color.clear] ] )
    .action_({|ctrl| MidiCtrl.connectAll; })
    .font_(Font(size:20))
    .fixedSize_(20)
    .toolTip_("midi connect")
    ;

    mediaBtn = Button().states_([ ["⚛︎", nil, Color.clear] ] )
    .action_({|ctrl| \midi.postln; })
    .font_(Font(size:20))
    .action_({
        M('device/media').().ui
    })
    .fixedSize_(20)
    .toolTip_("media")
    ;

    //serverGuiBtn = Button().states_([ ["s"] ]).action_({ T.serverGui  }).maxWidth_(20);
    transport = View()
    .layout_(HLayout(
        StaticText()
        .string_(" ")
        .mouseMoveAction_({|ctrl, x, y|
            var width, height;
            var bounds = ctrl.bounds;
            var screen = ctrl.mapToGlobal(Point(x, y));
            var screenX = screen.x;
            var screenY = screen.y;
            width = view.bounds.width;
            height = view.bounds.height;
            w.setTopLeftBounds(Rect(left:screenX, top:screenY, width: width, height: height), menuSpacer:0);
        }),
        mediaBtn,
        midiBtn,
        muteBtn, 
        recBtn,
        nil,
        tempoBox,
        //nil
    ).spacing_(1).margins_(1) )
    .background_(Color.grey.alpha_(0.25));
    
    outerlayout = VLayout(
        transport,
        listView.layout_(listLayout),
        nil
    ).spacing_(2).margins_(2);

    view = View(parent: w, bounds:200@250)
    .background_(Color.black)
    .layout_(outerlayout);

    refresh = {
        listView.children.do({|c|
            c.remove    
        });

        tracks = T.tracks;
        tracks.do({|t, i|
            var st;
            var playBtn, viewBtn, level, width, pan, fxBtn, muteBtn;
            var hlayout;
            var out_width = t.get(\out_width) ?? 1;
            var out_pan = t.get(\out_pan) ?? 0;
            var isplaying = if ( t.isPlaying ) {1} {0};
            var vol = t.get(\vol) ?? 1;
            //st = StaticText().string_(t.key);

            playBtn = Button().states_([ ["▷", t.color, Color.clear], ["☐", t.color, Color.clear] ])
            .font_(Font(size:20))
            .action_({|ctrl| if (ctrl.value == 1) { t.play }{ t.stop }  })
            .fixedSize_(20)
            .value_(isplaying);

            level = LevelSlider(t.key, spec: [0, 2, \lin, 0, 1].asSpec, color: t.color)
            .minWidth_(75)
            .maxHeight_(20)
            .action_({|ctrl|
                t.set(\vol, ctrl.value)    
            })
            .value_(vol);

            width = Knob()
            .fixedSize_(20)
            .background_(Color.clear)
            .color_([nil, t.color, nil, t.color])
            .action_({|ctrl|
                t.set(\out_width, ctrl.value)    
            })
            .value_(out_width);

            pan = Knob()
            .fixedSize_(20)
            .background_(Color.clear)
            .color_([nil, t.color, nil, t.color])
            .action_({|ctrl|
                var val = ctrl.value.linlin(0, 1, -1, 1);
                t.set(\out_pan, val)    
            })
            .value_(out_pan.linlin(-1, 1, 0, 1));

            viewBtn = Button().states_([ ["⛭", t.color, Color.clear] ])
            .font_(Font(size:20))
            .fixedSize_(20)
            .action_({|ctrl|
                t.gui("props")
            });

            /*
            fxBtn = Button().states_([ ["⧉", nil, Color.clear] ])
            .font_(Font(size:15))
            .maxWidth_(20)
            .action_({|ctrl|
                t.gui("fx")
            });
            */
            
            muteBtn = Button()
            .states_([ ["⨴", nil, Color.clear], ["⨵", Color.fromHexString("F28C28"), Color.clear] ])
            .action_({|ctrl| if (ctrl.value == 1) { t.mute }{ t.unmute } })
            .font_(Font(size:20))
            .fixedSize_(20)
            .toolTip_("mute");

            listLayout.add(level, i, 0);
            listLayout.add(playBtn, i, 1);
            listLayout.add(width, i, 2);
            listLayout.add(pan, i, 3);
            listLayout.add(viewBtn, i, 4);
            listLayout.add(muteBtn, i, 5);
        });
    };

    refresh.();
    T.addDependant(Fdef(\trackadded, {|obj, what, val|
        if (what == \trackadded) {
            refresh.()    
        }
    }));

    w.asView.front;
    //view.front
};
(func: func);
)