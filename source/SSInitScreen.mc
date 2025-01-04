import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Graphics;
import Toybox.Lang;

// dc.drawText(xcent1, ycent1, font, targDate_years.format("%.2f"), justify);

class SSInitView extends WatchUi.View{
    
   
    public function initialize(){
       
    }

    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);  
        dc.drawText(10, 10, 4, "THE PLANETS", Graphics.TEXT_JUSTIFY_LEFT);

    }
}

   

class SSInitDel extends WatchUi.BehaviorDelegate {

    
    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    } 

    public function onSelect() as Boolean { 

        //return [_solarSystemView, _solarSystemDelegate];
        //_solarSystemDelegate = null;
        //_solarSystemView = null;

        //pushView(solarSystemView_class, solarSystemDelegate_class, WatchUi.SLIDE_IMMEDIATE);
        var ret = SSBaseApp_class.getInitialSSView();
        WatchUi.pushView(ret[0], ret[1], WatchUi.SLIDE_RIGHT);
        
       
    }

    function onBack() {
        
        //save_menu = null;
        //solarSystemView_class = null;


        //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        //switchToView(solarSystemView_class, solarSystemBase_class._solarSystemDelegate, WatchUi.SLIDE_IMMEDIATE);
        //switchToView.popView(WatchUi.SLIDE_IMMEDIATE);
        //System.exit();
        //WatchUi.requestUpdate(); //often the screen is black after return from Menu, at least in the sim
        //return true;
        
         //since we usually/often get memory probs when returning from menu, we just exit the app
         
         return false;
    }
}
