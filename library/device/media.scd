(
var filesEnv = Environment.make({|self|

    var drawFiles, browse;
    var previous;
    var width = 600;
    var height = 600;
    var textHeight = 12;
    var filesTitle;
    var model;

    self.know = true;

    browse = {arg path;
        var folder = PathName.new(path);
        if (folder.isFolder, {
            var folders = folder.folders;
            var files = folder.files;
            files = files.select({|pn| [\wav, \aif, \aiff].includes(pn.extension.toLower.asSymbol) });
            [folders, files];
        }, {
            [];
        });
    };

    drawFiles = {arg path, view;

        var info = browse.(path);
        var folders = info[0];
        var files = info[1];
        var textwidth = width;//QtGUI.stringBounds(path).width;

        view.removeAll;
        view.decorator.reset;
        filesTitle.string_(path).resizeTo(textwidth, textHeight);

        StaticText.new(view, 10@textHeight)
        .string_("^")
        .stringColor_(Color.white)
        .mouseDownAction_({
            var pathName = PathName.new(path);
            drawFiles.(pathName.parentPath, view);
        });
        view.decorator.nextLine;

        folders.do({arg path;

            //var bounds = QtGUI.stringBounds(path.folderName);
            //var textwidth = bounds.width + 20;
            StaticText.new(view, textwidth@textHeight)
            .string_("> " ++ path.folderName)
            .stringColor_(Color.white)
            .mouseDownAction_({
                drawFiles.(path.fullPath, view);
            });
            view.decorator.nextLine;
        });

        files.do({arg path;

            //var bounds = QtGUI.stringBounds(path.fileName);
            //var textwidth = bounds.width + 20;
            var val = "+ " ++ path.fileName;

            StaticText(view, textwidth@textHeight)
            .string_(val)
            .stringColor_(Color.white)
            .canFocus_(true)
            .mouseDownAction_({|ctrl|
                if (previous.notNil) {
                    if (previous.isClosed.not) {
                        previous.background = Color.clear;
                    }
                };
                ctrl.background = QtGUI.palette.highlight;
                previous = ctrl;
                model.changed(\pathselected, path.fullPath)
            });
            view.decorator.nextLine;
        });

        view.decorator.nextLine;
        UserView(view, 100@100);
        view.decorator.nextLine;
    };

    self.initialize = {|self, path, argModel|

        var filesView;
        var view = View().layout_(VLayout());
        model = argModel;

        filesView = ScrollView()
        .background_(Color.black)
        .hasBorder_(false)
        .autohidesScrollers_(true)
        .minHeight_(height/2);

        filesView.decorator_(FlowLayout(filesView.bounds));
        filesTitle = StaticText();

        filesView.keyDownAction_({|ctrl, char, mod, unicode, keycode, key|
            //[char, mod, unicode, keycode, key].postln;  
            // down arrow
            if (key == 16777237) {
                \down.postln;
            };
            // up arrow
            if (key == 16777235) {
                \up.postln;
            };
            
            true;
        });

        view.layout.add(filesTitle);
        view.layout.add(filesView);
        drawFiles.(path, filesView);
        
        view
    }
});

var tagsEnv = Environment.make({|self|

    var drawTags;
    var previous;
    var width = 600;
    var height = 600;
    var textHeight = 12;
    var tagsTitle;
    var model;

    self.know = true;

    drawTags = {|tag, view|
        // 
        var folders = if (tag.isNil) { Tag.all.keys } { [] };
        var files = if (tag.isNil) { [] } { Tag.all[tag] };

        var titleText = if (tag.isNil) {""} {tag};
        var textwidth = width;//QtGUI.stringBounds(titleText).width;

        view.removeAll;
        view.decorator.reset;
        tagsTitle.string_(" " ++ titleText).resizeTo(textwidth, textHeight);

        if (tag.notNil) {
            StaticText.new(view, 10@textHeight)
            .string_("^")
            .stringColor_(Color.white)
            .mouseDownAction_({
                drawTags.(nil, view);
            });
            view.decorator.nextLine;
        };

        folders.do({|val|
            //var bounds = QtGUI.stringBounds(val);//.debug(\bounds);
            StaticText.new(view, textwidth@textHeight)
            .string_("> " ++ val)
            .stringColor_(Color.white)
            .mouseDownAction_({
                drawTags.(val, view);
            });
            view.decorator.nextLine;
        });

        files.do({arg val;

            var pn = PathName(val);
            //var bounds = QtGUI.stringBounds(pn.fileName);//.debug(\bounds);
            StaticText(view, bounds:textwidth@textHeight)
            .string_("+ " ++ pn.fileName)
            .stringColor_(Color.white)
            .canFocus_(true)
            .mouseDownAction_({|ctrl|
                if (previous.notNil) {
                    if (previous.isClosed.not) {
                        previous.background = Color.clear;
                    }
                };
                ctrl.background = QtGUI.palette.highlight;
                previous = ctrl;
                model.changed(\pathselected, val)
            });
            view.decorator.nextLine;
        });

        view.decorator.nextLine;
        UserView(view, 100@100);
        view.decorator.nextLine;
    };

    self.initialize = {|self, argModel|

        var tagsView;   
        
        var view = View().layout_(VLayout());
        model = argModel;
    
        tagsView = ScrollView()
        .background_(Color.black)
        .hasBorder_(false)
        .autohidesScrollers_(true)
        .minHeight_(height/2);

        tagsView.decorator_(FlowLayout(tagsView.bounds));
        tagsTitle = StaticText();

        view.layout.add(tagsTitle);
        view.layout.add(tagsView);
        drawTags.(nil, tagsView);

        view;
    };

});

var show = {arg path;
    
    var currentFile;
    var height = 600;
    var width = 600;
    var textHeight = 12;
    var view, detailsView, filesView, tagsView, winView, tracksView;
    var sendid = UniqueID.next.abs;
    var sfv, updatePlayer, synth, playFile;
    var time, pathTitle, playerView, playBtn, stopBtn, volSlider, infoBtn, clipBoardBtn, revealBtn, tagsEdit;
    var model = Ref();
    var autoplay = true;
    var simpleController = SimpleController(model);
    var filesTab, tagsTab, tabBar, stack;
    //var playEvents = List();

    (1..2).do({|v|
        var synthdef = "diskIn%_media".format(v).asSymbol;
        SynthDef(synthdef, { |out, amp=1, bufnum, sustainTime, atk=0|

            var gate, sig, gateEnv, env;
            var trig = \trig.tr(0);
            var rel = 0.1;
            
            gate = \gate.kr(1) + Impulse.kr(0);
            gate = (1 - trig) * gate;

            sig = PlayBuf.ar(v, bufnum, BufRateScale.kr(bufnum), trigger: trig, startPos: 0.0);
            gateEnv = EnvGen.kr(Env([1, 1, 0], [sustainTime-rel, 0]), gate: gate);
            env = EnvGen.kr(Env.asr(atk, 1, rel), gate * gateEnv, doneAction: Done.freeSelf);
            Out.ar(out, sig * env * amp)
            
        }).add;
    });

    OSCdef(\diskin, {|msg|
        var frame = msg[3];
        var id = msg[2];
        var numframes = currentFile.numFrames;
        var dur = currentFile.duration;

        var current = frame.min(numframes)/numframes;
        var sec = dur * current;

        var val = "%/%".format(
            sec.asTimeString(decimalPlaces:2),
            dur.asTimeString(decimalPlaces:2)
        );

        {
            if (id == sendid) {
                time.string = val;
            }
        }.defer;
        
    }, path: '/diskin');

    winView = View().layout_(HLayout().spacing_(0).margins_(0));
    tracksView = View().layout_(VLayout( Button() ));

    view = View(bounds: Rect(width:width, height:height) ) //w //Window(bounds: Rect(top: Window.screenBounds.height-300, left: 275, width:width, height:height), border: false)
    .layout_(VLayout().spacing_(0).margins_(0))
    .name_("media")
    .background_(Color.black);
    
    //winView.layout.add(view);
    //winView.layout.add(tracksView);
    detailsView = View().layout_(VLayout().margins_(0).spacing_(0)).background_(Color(0.2, 0.2, 0.2)); 
    filesView = filesEnv.initialize(path, model);
    tagsView = tagsEnv.initialize(model);

    stack = StackLayout( 
        View().layout_(VLayout(filesView)), 
        View().layout_(VLayout(tagsView))
    ).mode_(0);

    filesTab = Button().states_([ ["files", nil, nil] ] ).action_({ stack.index = 0 });
    tagsTab = Button().states_([ ["tags", nil, nil] ]  ).action_({ stack.index = 1 });
    tabBar = HLayout(filesTab, tagsTab);

    tagsEdit = TextField()
    .stringColor_(Color.white)
    .background_(Color.black)
    .action_({|ctrl|
        var vals = ctrl.value.split($,);
        var path = currentFile.path;
        vals.do({|v|
            var val = v.stripWhiteSpace;
            [val, currentFile.path].postln;
            Tag.tag(v, path)    
        })
    });

    sfv = SoundFileView()
    .gridOn_(true)
    .minHeight_(50)
    .drawsRMS_(true)
    .drawsCenterLine_(true)
    .drawsBoundingLines_(false)
    .gridColor_(Color.black)
    .background_(Color.black)
    .waveColors_([Color.white.alpha_(0.7), Color.white.alpha_(0.7)  ])
    .rmsColor_(Color.white)
    .peakColor_(Color.white)
    .gridResolution_(0.0) 
    .timeCursorOn_(false);

    time = StaticText()
    .string_("00:00:00.00/00:00:00.00")
    .background_(Color.black);

    pathTitle = DragSource()
    .background_(Color.clear)
    .bounds_(Rect(height: 50, width:750))
    .align_(\left);

    playerView = View().layout_(VLayout().margins_(1).spacing_(0));

    playFile = {|soundFile|

        var instr, id;
        var numchannels, synthdef;
        var sustainTime;
        var sampleRate;
        var numFrames;
        
        numFrames = soundFile.numFrames;
        numchannels = soundFile.numChannels;
        sampleRate = soundFile.sampleRate;
        synthdef = "diskIn%_media".format(numchannels).asSymbol;

        time.string_("00:00:00.00/%".format( soundFile.duration.asTimeString(decimalPlaces:2) ));
    
        sustainTime = (numFrames - 0) / sampleRate;
        Buffer.read( path:soundFile.path, action:{|buf|
            //synth.isPlaying.debug("isPlaying");
            if (synth.isNil) {
                synth = Synth(synthdef, [\bufnum, buf.bufnum, \sustainTime, sustainTime, \gate, 1, \out, 4])
                .onFree({

                    synth.debug("synth free");
                    buf.free;
                    synth = nil;

                    {
                        playBtn.value = 0;
                    }.defer
                });
                synth.register;
            } {
                //synth.isRunning.debug("isRunning");
                synth.set(\bufnum, buf.bufnum, \trig, 1, \sustainTime, sustainTime)    
            }
            //playEvents.addFirst(synth);
        });
    };

    updatePlayer = {|path|
        currentFile = SoundFile();
        currentFile.openRead(path);
        sfv.soundfile = currentFile;
        sfv.read(0, currentFile.numFrames);

        volSlider.value = 1;
        time.string_("00:00:00.00/%".format( currentFile.duration.asTimeString(decimalPlaces:2) ));
        pathTitle.object_(path).string_(PathName(currentFile.path).fileName).toolTip_(path);
    };

    playBtn = Button()
    .states_([ [">", nil, nil], ["[]", nil, nil] ])
    .fixedSize_(20)
    .action_({|ctrl|
        if (ctrl.value == 1) {
            model.changed(\play);
        } {
            model.changed(\stop);    
        }
    });

    volSlider = LevelSlider("vol")
    .value_(1)
    .action_({|ctrl|
        model.changed(\vol, ctrl.value);
    });

    infoBtn = Button()
    .states_([ ["i", nil, nil] ])
    .fixedSize_(20)
    .action_({|ctrl|
        model.changed(\info);
    });

    clipBoardBtn = Button()
    .states_([ ["c", nil, nil] ])
    .fixedSize_(20)
    .action_({ model.changed(\clipboard) });

    revealBtn = Button()
    .states_([ ["^", nil, nil] ])
    .fixedSize_(20)
    .action_({
        model.changed(\revealinfinder);
    });

    playerView.layout.add(pathTitle);
    playerView.layout.add (tagsEdit );
    playerView.layout.add(sfv);
    playerView.layout.add (time);
    playerView.layout.add( 
        HLayout(playBtn, volSlider, infoBtn, clipBoardBtn, revealBtn )
        .margins_(3).spacing_(1)
    );

    detailsView.layout.add(playerView);

    view.layout.add(tabBar);
    view.layout.add(stack);
    view.layout.add(detailsView);

    // ************************************************
    // Event handlers
    simpleController.put(\pathselected, {|obj, what, path|
        updatePlayer.(path);
        if (autoplay) {
            playFile.(currentFile);
            {
                playBtn.value = 1;
            }.defer;//(0.3)
        }
    })
    .put(\play, {|obj, what, val|
        playFile.(currentFile)
    })
    .put(\stop, {|obj, what, val|
        synth.release(0.01)
    })
    .put(\info, {|obj, what, val|
        var sec = File.mtime(currentFile.path);
        var dte = Date.fromRawSeconds(sec).asctime;
        var size = File.fileSize(currentFile.path);
        var str = 
        "frames:   %\n" ++
        "duration: %\n" ++
        "format:   %\n" ++
        "rate:     %Hz\n" ++
        "path:     %\n" ++
        "modified: %\n" ++
        "size:     %M";
        
        str.format(
            currentFile.numFrames, 
            currentFile.duration.asTimeString(decimalPlaces:2),
            currentFile.sampleFormat, 
            currentFile.sampleRate,
            currentFile.path,
            dte,
            (size * 0.000001).trunc(0.01)
        ).postln;
    })
    .put(\clipboard, {|obj, what, val|
        "echo \"%\" | /usr/bin/pbcopy".format(currentFile.path).unixCmd;
        "copied to clipboard".postln;
    })
    .put(\revealinfinder, {|obj, what, val|
        "open -R \"%\"".format(currentFile.path).unixCmdGetStdOut.postln
    })
    .put(\vol, {|obj, what, val|
        synth.set(\amp, val)        
    });

    view
    .onClose_({
        if (currentFile.notNil) {
            currentFile.close
        };
        
        synth.debug("release").release(0.01)        
    });

    //winView
};

// expose the module
(
func: {
    // TODO: this needs to be configurable
    var path = "/Users/david/Documents/supercollider/media/";
    var view = show.(path);
    (
        view: view,
        ui: { view.front }
    )
}
)
)



    