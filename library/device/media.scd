(
var currentFile;

var browse = {arg path;
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

var show = {arg path;
	
	var height = 200;
	var width = 200;
    var browser, previous, view, cv, draw, detailsView, loadSfv, scroll, title, w;

    var win = Window("Browser", Rect(0, 0, 200, 200));
	win.asView.decorator_(FlowLayout(bounds:win.bounds));
	win.background_(Color.black);

    scroll = ScrollView(win, win.bounds)
    .background_(Color.black)
    .hasBorder_(false)
    .autohidesScrollers_(true)
    .minHeight_(height/2)
    ;
	scroll.decorator_(FlowLayout(scroll.bounds));

    w = Window(bounds: Rect(top: Window.screenBounds.height-300, left: 275, width:width, height:height), border: true);
	view = w //Window(bounds: Rect(top: Window.screenBounds.height-300, left: 275, width:width, height:height), border: false)
    .layout_(VLayout().spacing_(0).margins_(0))
    .asView
    .name_("media")
    .background_(Color.black);
	
    detailsView = View().layout_(VLayout().margins_(0).spacing_(0)).background_(Color(0.2, 0.2, 0.2)); 

    title = StaticText()
    .mouseMoveAction_({|ctrl, x, y|
        var width, height;
        var bounds = ctrl.bounds;
        var screen = ctrl.mapToGlobal(Point(x, y));
        var screenX = screen.x;
        var screenY = screen.y;
        //width = 200;//view.sizeHint.width;
        //height = 200;//view.sizeHint.height;
        width = view.bounds.width;
        height = view.bounds.height;

        //\here.postln;
        //[ctrl.bounds, view.bounds].debug("info");
        w.setTopLeftBounds(Rect(left:screenX, top:screenY, width: width, height: height), menuSpacer:0);
    })
    ;

    view.layout.add(title);
    view.layout.add(scroll);
    view.layout.add(detailsView);

    loadSfv = {|path|

        var player;

        var sfv = SoundFileView()
        .gridOn_(false)
        .minHeight_(50)
        .drawsRMS_(false)
        .drawsCenterLine_(true)
        .drawsBoundingLines_(false)
        .gridColor_(Color.black)
        .background_(Color.black)
        .waveColors_([Color.white, Color.white])
        .gridResolution_(0.0) 
        .timeCursorOn_(false)
        //.maxHeight_(50)
        ;

        currentFile = SoundFile();
        currentFile.openRead(path);
        sfv.soundfile = currentFile;
        sfv.read(0, currentFile.numFrames);
        currentFile.cue(ev: (amp: 1), playNow:true, closeWhenDone: true);

        player = View().layout_(VLayout(
            
            DragSource()
            .background_(Color.clear)
            .bounds_(Rect(width:750))
            .align_(\left)
            .object_(path)
            .string_(PathName(currentFile.path.debug("media path")).fileName)
            .toolTip_(path),
            
            HLayout(

                sfv,

                /*
                View().layout_(VLayout(
                    GridLayout.rows(
                        [
                            [
                                HLayout(
                                    Button().states_([ [">"] ]).action_({
                                        currentFile.cue(playNow:true, closeWhenDone: true)
                                    })
                                    .maxSize_(30),

                                    Button().states_([ ["^"] ]).action_({
                                        // TODO: mac only
                                        "open -R \"%\"".format(path).unixCmdGetStdOut.postln
                                    })
                                    .maxSize_(30),

                                    Button().states_([ ["i"] ]).action_({
                                        var chans = if ( currentFile.numChannels > 1 ) { [0, 1] } { [0] };

                                        var instr = InstrProxy()
                                        .synth(0, \sig, \sampler, cb:{|m| m.numchannels = currentFile.numChannels })
                                        .synth(2, \env, \asr)
                                        .set(\amp, 1, \bufpath, path);

                                        { instr.gui }.defer(1);

                                        // TODO: need a way to expose these so they can opened later
                                        // if the windows are closed
                                        if (~instrs.isNil) {
                                            ~instrs = List();
                                        };
                                        ~instrs.add(instr);

                                        B.read(path, chans, cb: {|buf|
                                            instr.set(\buf, buf);
                                        })
                                    })
                                    .maxSize_(30)
                                ),
                                columns: 2
                            ]
                        ],
                        [ StaticText().string_("sf"), StaticText().string_(currentFile.sampleFormat)],
                        //[ StaticText().string_("hf"), StaticText().string_(currentFile.headerFormat)],
                        [ StaticText().string_("fr"), StaticText().string_(currentFile.numFrames)],
                        //[ StaticText().string_("ch"), StaticText().string_(currentFile.numChannels)],
                        [ StaticText().string_("sr"), StaticText().string_(currentFile.sampleRate)],
                        [ StaticText().string_("dur"), StaticText().string_(( currentFile.numFrames/currentFile.sampleRate ).trunc(1/32))]
                    ),
                    nil
                ).margins_(1).spacing_(1)).background_(Color(0.3, 0.3, 0.3))
                */
            ).margins_(2).spacing_(5)
        ).margins_(1).spacing_(1));

        detailsView.children.do({|child| child.remove});
        detailsView.layout.add(player);
    };

    draw = {arg path, view;

		var pathName = PathName.new(path);
		var info = browse.(path);
		var folders = info[0];
		var files = info[1];
        // TODO: not sure how to actually calculate this
        // is this derived from font-size?
        var height = 12;
        var textwidth = path.size * 10;

		view.removeAll;
		view.decorator.reset;


		//StaticText(view, textwidth@height)
        title.string_(path).resizeTo(textwidth, height);
		//.stringColor_(Color.white);
		//view.decorator.nextLine;

		StaticText.new(view, width@height)
		.string_("^")
		.stringColor_(Color.white)
		.mouseDownAction_({
			draw.(pathName.parentPath, view);
		});
		view.decorator.nextLine;

		folders.do({arg path;
			StaticText.new(view, textwidth@height)
			.string_("> " ++ path.folderName)
			.stringColor_(Color.white)
			.mouseDownAction_({
				draw.(path.fullPath, view);
			});
			view.decorator.nextLine;
		});

		files.do({arg path;
			StaticText(view, textwidth@height)
			.string_("+ " ++ path.fileName)
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
                loadSfv.(path.fullPath);
			});
			view.decorator.nextLine;
		});

        view.decorator.nextLine;
        StaticText(view, width@height).string_("....");
        view.decorator.nextLine;
	};

	draw.(path, scroll);

    view
    .onClose_({
        if (currentFile.notNil) {
            currentFile.close
        }
    });
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



