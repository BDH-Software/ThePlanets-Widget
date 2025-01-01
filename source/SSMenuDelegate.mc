import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Position;


enum {
    extraPlanets =  0,
    planetLabels = 1,
    //smallerBanners = 2,
    planetSizeL = 3,
    planetSizeS = 4,
    lastLoc_saved = 99,
}

var Options; //values added in getInitialView

var defOptions; //values added in getInitialView

var numOptions = 4;

var helpOption_enum = 5;

var save_menu as SSMenu?;

class SSMenu extends WatchUi.Menu2{
    
    public function initialize(){
        var OptionsLabels = ["Show extra planets?", "Show planet labels?", "Draw planets larger?", "Draw planets smaller?"];

        for (var i = 0; i < numOptions; i++) {
        Menu2.addItem(new WatchUi.ToggleMenuItem(OptionsLabels[i], null, Options[i], $.Options_Dict[Options[i]]==true, null));
        }

        planetAbbreviation_index = -1;
        var pA = getPlanetAbbreviation();
        Menu2.addItem(new WatchUi.MenuItem("Help & Planet Abbreviations", pA,helpOption_enum, {}));
        save_menu = self;
    }

    var planetAbbreviation_index = 0;
    
    // Function to generate planet abbreviation and name
    function getPlanetAbbreviation() {
        var helpSTR = f.toArray(WatchUi.loadResource($.Rez.Strings.help_strings) as String,  "|", 0);
        planetAbbreviation_index = (planetAbbreviation_index + 1) %(allPlanets.size() + helpSTR.size() - 1); //-1 bec we are skipping SU=SUN

        //return the info from HelpSTR
        if (planetAbbreviation_index < helpSTR.size()) {
            return helpSTR[planetAbbreviation_index];
        }   
        //Otherwise, return it from the list of all planets
        var tIndex = planetAbbreviation_index - helpSTR.size() + 1; //+1 bec we are skipping SU=SUN
        var planetName = allPlanets[tIndex];
        return planetName.substring(0, 2) + " " + planetName;
        
    }
}

class SSMenuDel extends WatchUi.Menu2InputDelegate {

    
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    } 

    public function onSelect(menuItem as MenuItem) as Void { 
        
        var ret = menuItem.getId();  
        if (menuItem instanceof ToggleMenuItem) {
            
            
            //deBug("menret", [ret, menuItem]);
            $.Options_Dict[ret] = menuItem.isEnabled();
            Storage.setValue(ret, menuItem.isEnabled());   

            //f.deBug("menu", [Options_Dict[extraPlanets], Options_Dict]);   
            if (ret == planetSizeL && menuItem.isEnabled) {                
                $.Options_Dict[planetSizeS] =false;
                Storage.setValue(planetSizeS, false);
                var r2 =  save_menu.findItemById(planetSizeS);
                //f.deBug("r2", r2);
                var x = save_menu.getItem(r2);
                //f.deBug("xr2", x);
                x.setEnabled(false);
            }   
            if (ret == planetSizeS && menuItem.isEnabled) {                
                $.Options_Dict[planetSizeL] =false;
                Storage.setValue(planetSizeL, false);
                var r2 =  save_menu.findItemById(planetSizeL);
                var x = save_menu.getItem(r2);
                x.setEnabled(false);
            }


        } else {
            //helpOption
            if(ret.equals(helpOption_enum)) {
                //var index = $.Options_Dict[id] |0;                                          
                menuItem.setSubLabel(save_menu.getPlanetAbbreviation());
            }
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate(); //often the screen is black after return from Menu, at least in the sim
    }
}
