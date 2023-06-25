(
func: {|node|

    var paths;
    var path = DMModule.libraryDir ++ "fx/";
    var fxmenu, browse;
    var vstlist = Library.at(\vstlist);

    var vsts = {
        if (vstlist.isNil) {
            
            var plugins = List.new;
            // TODO: remove dependency on V class
            var list = V.ls
            .reject({arg val;
                var plugin = VSTPlugin.plugins[val.asSymbol];
                plugin.isNil
                or: {
                    VSTPlugin.plugins[val.asSymbol].category.contains("Instrument")
                }
                or: {
                    VSTPlugin.plugins[val.asSymbol].category.contains("Synth")
                }
            });
 
            vstlist = list.asArray.sort;
            Library.put(\vstlist, vstlist)
        };

        vstlist
    };

    browse = {arg path, files=List.new;
        var folder = PathName.new(path);
        if (folder.isFolder) {
            var folders = folder.folders;
            files = files.addAll(folder.files);
            folders.do({arg folder;
                browse.(folder.fullPath, files);
            });
        };
        files;
    };

    paths = browse.(path);

    StaticText().string_("...")
    .setContextMenuActions(
        *(
            paths.collect({arg path;
                var name = path.folderName ++ '/' ++ path.fileNameWithoutExtension;
                MenuAction( name, {arg action, what, value;

                    var id = action.string.asSymbol;
                    var maxindex;

                    maxindex = node.objects.indices
                    .reject({|val| val < 100 or: {val >= 1000} }).maxItem ?? {100};

                    node.fx(maxindex + 10, id);
                });
            })
            ++ vsts.().collect({arg vst;
                MenuAction(vst, {arg action;

                    var id = "vst:%".format(action.string).asSymbol;
                    var maxindex;

                    maxindex = node.objects.indices
                    .reject({|val| val < 100 or: {val >= 1000} }).maxItem ?? {100};

                    node.fx(maxindex + 10, id);
                })
            })
        )
    );
}
)
