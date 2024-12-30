import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Position;


enum {
    extraPlanets =  0,
    planetLabels = 1,
    smallerBanners = 2,
    planetSizeL = 3,
    planetSizeS = 4,
    lastLoc_saved = 99,
}

var Options = [extraPlanets, planetLabels, smallerBanners, planetSizeL, planetSizeS];
var OptionsLabels = ["Show extra planets?", "Show planet labels?", "Show smaller banners?", "Larger planets?", "Smaller planets?"];
var defOptions = {extraPlanets => false,
                  planetLabels => false,      
                    smallerBanners => false,
                    planetSizeL => false,
                    planetSizeS => false,
                    lastLoc_saved => [38, -94],
                    };

var numOptions = 5;

class SSMenu extends WatchUi.Menu2{
    public function initialize(){

        for (var i = 0; i < numOptions; i++) {
        Menu2.addItem(new WatchUi.ToggleMenuItem(OptionsLabels[i], null, Options[i], $.Options_Dict[Options[i]]==true, null));
        }
    }
}

class SSMenuDel extends WatchUi.Menu2InputDelegate {

    
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    } 

    public function onSelect(menuItem as MenuItem) as Void { 

         if (menuItem instanceof ToggleMenuItem) {
            
        var ret = menuItem.getId();  
        deBug("menret", [ret, menuItem]);
        $.Options_Dict[menuItem.getId().toString()] = menuItem.isEnabled();
        Storage.setValue(ret, menuItem.isEnabled());        

        }
    }
}
