import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Position;
import Toybox.Time.Gregorian;
import Toybox.Time;

/*

(:glance)class SSGlanceApp extends Application.AppBase {
    private var _SSGlanceView as SSGlanceView;
    private var _SSGlanceDelegate as SSGlanceDelegate;
    
    public function initialize() {
        AppBase.initialize();
        System.println("init starting...");

        //_SSGlanceView = new $.SSGlanceBaseView();
        //_SSGlanceDelegate = new $.SSGlanceBaseDelegate(_SSGlanceView);
    }

    function getGlanceView() {
        return [ new SSGlanceView() ];
    }
    public function onStart(state as Dictionary?) as Void {
    }

    public function onStop(state as Dictionary?) as Void {
    }

    public function onPosition(info as Position.Info) as Void {
    }

    public function getInitialView() as [Views] or [Views, InputDelegates] {
        return [_SSGlanceView, _SSGlanceDelegate];
            _SSGlanceDelegate = null;
            _SSGlanceView = null;

    }
    
}
*/

/*
(:glance)class SSGlanceDelegate extends WatchUi.BehaviorDelegate {
    private var _mainview as SSGlanceView?;
    public function initialize() {}
}
*/
var sm; 

(:glance)class SSGlanceView extends WatchUi.GlanceView {
    //private var _mainview as SSGlanceView?;

    var am,pm;

    public function initialize() {
        GlanceView.initialize();

        var obliq_deg;
        var pp;
        var moon_info3;

        obliq_deg=  f.calc_obliq_deg ($.now_info, $.now);

        allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
        var v = new vs();
        pp = v.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :ecliptic_latlon, allPlanets.slice(0,10));
        v = null;
        allPlanets = null;

        sm = new simpleMoon();
        moon_info3 = sm.eclipticPos_moon ($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs);
        sm = null;

        

        pp.put("Moon", [moon_info3[0]]);    
        moon_info3=null;    

        //var moon_age_deg = f.normalize ((pp["Moon"][0]) - (pp["Sun"][0]));

        var keys = pp.keys();
        var sorted_ang = new Array<Number> [keys.size()];
        for (var i = 0; i < keys.size(); i++) {
            var ky = keys[i];
            var ang_rad =  -equatorialLong2eclipticLong_rad(Math.toRadians(pp[ky][0]) , Math.toRadians(obliq_deg)); 

            pp.put(ky,(f.normalize(Math.toDegrees(ang_rad))).toNumber());
            //pp.put(ky,(f.normalize(Math.toDegrees(pp[ky][0]))*10).toNumber());
            
            //Create a sorted list of keys while we're at it..
            if (i==0) {sorted_ang[0] = i;
            } else {
                

                for (var j=0;j<=sorted_ang.size();j++) {
                    var myStats = System.getSystemStats();
                    System.println("Mem" + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
                    f.deBug("PP", [keys, ky, pp[ky], j, sorted_ang]);
                    if (sorted_ang[j] == null || pp[ky] < pp[keys[sorted_ang[j]]]) {

                        var s1 = sorted_ang.slice(0,j);
                        var s2 = sorted_ang.slice(j,sorted_ang.size()-1);
                        f.deBug("SRT", [s1, s2, i, j]);
                        sorted_ang = s1;
                        sorted_ang.add(i);
                        sorted_ang.addAll(s2);
                        break;
                    }
                    //sorted_ang.add(i);
                }
            }
            

        }
        f.deBug("angs", [sorted_ang, pp]);
        am = "A:";
        pm = "P:";
        var hitsun = false;
        var sun = 0;
        var sun_ang;
        for (var i = 0; i < sorted_ang.size() * 2; i++) {
            var ky = keys[sorted_ang[i % sorted_ang.size()]];
            //var ang_rad = -srs.equatorialLong2eclipticLong_rad(Math.to Radians(pp[ky][0]), Math.toRadians(obliq_deg));  
            f.deBug("ky", [i,ky]);     

            if (ky.equals("Sun")) {
                if (hitsun) {break;}
                hitsun = true; 
                sun_ang = pp[ky];
                sun = i;
                continue;
            }
            f.deBug("ky", [i,ky, hitsun]);     
            if (hitsun) {
                f.deBug("norm1", [f.normalize(pp[ky] - sun_ang), pp[ky], ky, sun_ang]);
                if (f.normalize(pp[ky] - sun_ang) < 300) 
                {
                  am += ky.substring(0,2); 
                }
                f.deBug("sas", (sun - i - 1 + 2* sorted_ang.size()) % sorted_ang.size());
                var k2= (2*sun - i + 2* sorted_ang.size())%sorted_ang.size();
                f.deBug("norm2", [f.normalize(sun_ang - pp [keys[sorted_ang[k2]]]), pp[keys[sorted_ang[k2]]], k2, sun_ang, keys[sorted_ang[k2]]]);
                if ( f.normalize(sun_ang - pp[keys[sorted_ang[k2]]]) < 300) {
                    pm += keys[sorted_ang[k2]].substring(0,2);
                }
            }
        }
        pp = null;
        //speeds = null;
        //OptionsLabels = null;
        //Options = null;
        //defOptions = null;
        //srs.sunEventData = null;
        //Options_Dict = null;
        //allPlanets = null;
        //latlonOption_value = null;
        planetSizeOption_values = null;
        refreshOption_values = null;
        

        now_info = null;
        now = null;
        time_now = null;
        //f.deBug("mi3", moon_info3);

    }

    function onUpdate(dc) {

        //dc.drawText(130,0, Graphics.FONT_SMALL, "Here we are!", Graphics.TEXT_JUSTIFY_CENTER);

        /*var zTime = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        var zuluTime = Lang.format("$1$:$2$", [zTime.hour.format("%02d"), zTime.min.format("%02d")])+" Z";
        */

        

        //var whh = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0); 

        

        //var pp = vs.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :ecliptic_latlon, ["Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn"]); 

        f.deBug("ap", allPlanets);

        
        //allPlanets = null; 



        
        
       /*
        for (var rra_deg = 0; rra_deg<360;rra_deg += 360) {
            var ddecl = 0;
            if (rra_deg == 90) { ddecl = obliq_deg;}
            if (rra_deg == 270) { ddecl = obliq_deg;}
            //pp.put("Ecliptic"+rra_deg, [f.normalize(pp["Sun"][0] + rra_deg), ddecl]);
            pp.put("Ecliptic"+rra_deg, [rra_deg, ddecl, 50]);
        }
        */
    

        





        
        //var angs ={};
        
        



        

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0,0, Graphics.FONT_SMALL, am, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0,dc.getFontHeight(Graphics.FONT_SMALL), Graphics.FONT_SMALL, pm, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_LEFT);



    }
}

/*(:glance)function getApp() as SSGlanceApp {
    return Application.getApp() as SSGlanceApp;
}*/