
(
var oscpath = '/cutoff';
var li, msv, palette;
var view = View(bounds:Rect(width: 150))
.layout_(VLayout().margins_(0).spacing_(0));

li = LevelIndicator()
.warning_(1)
.critical_(1)
.style_(\continuous)
.value_(0.5);

palette = QPalette()
.window_(Color.clear)
.windowText_(Color.grey(0.5))
.baseText_(Color.grey(0.5))
.highlight_(Color.clear);

palette.base = Color.black;
palette.setColor(Color.black, \shadow);

msv = MultiSliderView()
.editable_(false)
.palette_(palette)
.maxHeight_(20)
.gap_(0)
.size_(1)
.reference_( [0.5] )
.indexIsHorizontal_(false)
.thumbSize_(20)
.background_(Color.clear)
.elasticMode_(0)
.isFilled_(true)
.fillColor_(Color.green)
.strokeColor_(Color.clear)
.value_( [0.5] );

OSCdef(oscpath, {|msg|
    var val = msg[3];
    var ref = msg[4];
    val = val.linlin(20, 20000, 0, 1);
    ref = ref.linlin(20, 20000, 0, 1);
    //val.postln;
    {
        if (val.notNil) {
            li.value = val;
            msv.value = val.asArray;
            msv.reference = ref.asArray
        }
    }.defer

}, oscpath);

//view.layout.add(li);
view.layout.add(msv);
view.front
)