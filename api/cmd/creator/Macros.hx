package api.cmd.creator;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
#end

class Macros {
    
    #if macro
    static function getTemplate(templateType:String):ExprOf<Map<String, String>> {
        // get the current fields of the class
        var fields:Array<Field> = Context.getBuildFields();

        var posInfos = Context.getPosInfos(Context.currentPos());
        var directory = Path.directory(FileSystem.fullPath(posInfos.file));

        // get the current class information. 
        var ref:ClassType = Context.getLocalClass().get();
        var templatePath:String = Path.join([directory, 'tpl', templateType]);

        if (FileSystem.exists(templatePath) && FileSystem.isDirectory(templatePath)) {
            
            var templateFiles:Array<Expr> = [];
            for (f in FileSystem.readDirectory(templatePath)) {
                
                var content = sys.io.File.getContent(templatePath + '/$f');
                templateFiles.push(macro $v{f} => $v{content});
            }
            
            // return as expression
            return macro $a{templateFiles};
        }  else {
            return macro null;
        }
    }
    #end

    public static macro function getHxTemplate():ExprOf<Map<String, String>> {
        return getTemplate('hx');
    }

    public static macro function getJsTemplate():ExprOf<Map<String, String>> {
        return getTemplate('js');
    }
}