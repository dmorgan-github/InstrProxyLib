(
var node = ~cxe;
var func = {

    var img = Image("/Users/david/Documents/supercollider/media/images/460px-Fotothek_df_tg_0003629_Geometrie_5E_Architektur_5E_Perspektive_5E_Polyeder.jpeg");
    var win = Window(bounds:Rect(0, 0, 200, 200));
    var but = Knob(win, Rect(84, 95, 50, 50)).background_(Color.black.alpha_(0.3));

    //var mod = UiModule('props').view(node).alpha_(0.2);
    //View(win, Rect(10, 10, 200, 200)).layout_(VLayout(mod));
    //mod.parent = win;

    win.asView.backgroundImage_(img);
};

(
func: func
);

)
