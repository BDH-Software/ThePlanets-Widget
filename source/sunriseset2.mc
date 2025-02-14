/*************************************************************
*
* Adapted directly from:
* SolarSystem by Ioannis Nasios 
* https://github.com/IoannisNasios/solarsystem
*
* LICENSE & COPYRIGHT of original code:
* The MIT License, Copyright (c) 2020, Ioannis Nasios
*
* Monkey C/Garmin IQ version of the code, with many modifications,
* Copyright (c) 2024, Brent Hugh. Released under the MIT license.
*
***************************************************************/

using Toybox.Math;
using Toybox.System;
import Toybox.Lang; 

//from .functions import f.normalize

///This works just great but were not using it now due to memory issues
/*
class sunRiseSet_cache2{

    var g_cache;
    var indexes;
    var MAX_CACHE = 0;

    function initialize () {
        

        //planetoncenter = $.Geocentric.planetoncenter;
        //objectlist = $.Geocentric.objectlist;
        g_cache = {};
        indexes = [];
    }

    function fetch (year, month, day, UT, dst, timeAdd_hrs, 
                 lat, lon) {

        //changing lat or lon by 1 degree equal about 4 mins difference in sunrise/set
        //so for our purposes +/- 4 mins or 6 mins is not really perceptible on screen.
         var lon_index = (lon/3.0).toNumber();
         var lat_index = (lat/3.0).toNumber();
                    
        //since we must incl lat & lon to get a sensible answer, might as well
        //includ UT & dst as well, as those are localized in the same way                    
        //var index = year+"|"+month+"|"+day+"|"+ UT+dst +"|"+lat_index+"|"+ lon_index;

        var time_mod = Math.round(0.0 + timeAdd_hrs/24.0 + f.julianDate(year, 
            month, day, 0, 0, UT, dst)).toNumber();
        var index = time_mod + "|"+ +"|"+lat_index+"|"+ lon_index;
        var ret;

        var myStats = System.getSystemStats();

        //System.println("Memory/sunriseset: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory + " MAX_CACHE: " + MAX_CACHE);
        //myStats = null;

        if (g_cache.hasKey(index)) {
            ret = g_cache[index];
            //kys = ret.keys();
            } 
        else {
            //we always cache the info for midnight UTC & all objects
            
            if (myStats.freeMemory<5500) {
                MAX_CACHE = 0;
                self.empty();                                 
            
            } else if (myStats.freeMemory<9500) {
                MAX_CACHE -=1;
                if (MAX_CACHE < 0) { MAX_CACHE = 0; }
                if (indexes.size() > MAX_CACHE -1 && indexes.size() > 0) {
                    g_cache.remove(indexes[0]);
                    indexes.remove(indexes[0]);
                }
            }
            else if (myStats.freeMemory> 20000 && MAX_CACHE<60) {MAX_CACHE +=1;}

            if (indexes.size() > MAX_CACHE -1 && g_cache.size()>0) {
                g_cache.remove(indexes[0]);
                indexes.remove(indexes[0]);
            }
            //var g = new sunRiseSet(year, month, day, UT,dst, timeAdd_hrs, lat, lon);
            //ret = g.riseSet();
            //kys = ret.keys();
            g_cache.put(index,ret);
            indexes.add(index);
        }                    

        return ret;
    }

    public function empty () {
        
        g_cache = {};
        indexes = [];
    }
    
}

*/


//class srs {
module srs {
    enum {
        //GMST_MID_HR,
        TRANSIT_GMT_HR,
        //GMST_NOW_HR,
        //LMST_NOW_HR,
        ASTRO_DAWN,
        //NAUTIC_DAWN,
        DAWN,
        //BLUE_HOUR,
        SUNRISE,
        //SUNRISE_END,
        //HORIZON,
        //GOLDEN_HOUR,
        NOON,
    }

    //for testing, can delete later
    /*
    var sevent_names = {
        :GMST_MID_HR => "GMST_MID_HR",
        :TRANSIT_GMT_HR => "TRANSIT_GMT_HR",
        :GMST_NOW_HR => "GMST_NOW_HR",
        :LMST_NOW_HR => "LMST_NOW_HR",
        :ASTRO_DAWN => "Astronomical Dawn",
        :NAUTIC_DAWN => "Nautical Dawn",
        :DAWN => "Dawn",
        :BLUE_HOUR => "Blue Hour",
        :SUNRISE => "Sunrise",
        :SUNRISE_END => "Sunrise End",
        :HORIZON => "Horizon",
        :GOLDEN_HOUR => "Golden Hour",
        :NOON => "Noon",
        "Ecliptic0" => "Spring Equinox",
        "Ecliptic90" => "Summer Solstice",
        "Ecliptic180" => "Fall Equinox",
        "Ecliptic270" => "Winter Solstice",
    };
    */



    /*
            public var sunEventData = {
            :ASTRO_DAWN => [-18, :AM],
            :NAUTIC_DAWN => [-12, :AM],
            :DAWN => [-6, :AM ],
            :BLUE_HOUR_AM => [-4, :AM],
            :SUNRISE => [-.833, :AM],
            :SUNRISE_END => [-.3, :AM],
            :HORIZON_AM => [0, :AM],
            :GOLDEN_HOUR_AM => [6, :AM],
            :NOON => [null, :PM], //noon is the highest point or whatever, but not a certain # of degrees
            :GOLDEN_HOUR_PM => [6, :PM],
            :HORIZON_PM => [0, :PM],
            :SUNSET_START => [-0.3, :PM],
            :SUNSET => [-.833, :PM],
            :BLUE_HOUR_PM => [-4, :PM],
            :DUSK => [-6, :PM],
            :NAUTIC_DUSK => [-12, :PM],
            :ASTRO_DUSK  => [-18, :PM], 
            //:SIDEREAL_TIME => [null, :PM],
        };
        */


        public var sunEventData = {
            :ASTRO_DAWN => -18,  //each one has  a twin @ - it's number, so we'll just combine the two & you can figure it out. Dawn/Dusk -18/+18, etc.
            :NAUTIC_DAWN => -12,
            :DAWN => -6 ,
            //:BLUE_HOUR => -4,
            //:SUNRISE => -.833, //Sunset  START
            :SUNRISE => -.56667, //Sunset MIDDLE OF SUN (so we're not counting the top of the sun, but the middle)
            :SUNRISE_END => -.3, //Sunset start
            //:HORIZON => -0.5667, //For stars, planets, etc, the horizon where  they  can first be seen, "star-rise".  This is not 0 thanks to refraction etc.
            //:GOLDEN_HOUR => 6,
            :NOON => null, //noon is the highest point or whatever, but not a certain # of degrees below the horizon

        };
            
            //degrees above / below the horizon for these events
            /*
        public const TIMES = [
            -18,    // ASTRO_DAWN
            -12,    // NAUTIC_DAWN
            -6,     // DAWN
            -4,     // BLUE_HOUR
            -0.833, // SUNRISE
            -0.3,   // SUNRISE_END
            6,      // GOLDEN_HOUR_AM
            null,         // NOON
            6 ,
            -0.3,
            -0.833,
            -4,
            -6,
            -12,
            -18,
            ];
            */

        /* **************************************************************************
        Outputs Dictionary with all sun events for the day + Sidereal_Time EVENT_NAME => [time, name_str].  See enum with EVENT_NAMEs above.
        If any events do not happen (ie sunrise & set during polar summer) their time will be a null.
        
        Args:
            year (int): Year (4 digits) ex. 2020.
            month (int): Month (1-12).
            day (int): Day (1-31).
            UT: Time Zone (deviation from UT, -12:+14), ex. for Greece (GMT + 2) 
                enter UT = 2.
            dst (int): daylight saving time (0 or 1). Wheather dst is applied at 
                    given time and place.
            longitude (float): longitude of place of Sunrise - Sunset in decimal format.
            latitude (float): latitude of place of Sunrise - Sunset in decimal format.
        ***************************************************************************/
    

    //By Greg Miller gmiller@gregmiller.net celestialprogramming.com
    //Released as public domain
    //'use strict';


    //Corrects values to make them between 0 and 1
    function constrain(v){
            //console.log(v);
            while(v<0){v+=1;}
            while(v>1){v-=1;}
            return v;
    }

    //returns solar event times in HOURS
    //function getRiseSetfromDate_hr(year, month, day, UT, dst, time_add_hrs, 
    //             lat_deg, long_deg) {
    function getRiseSetfromDate_hr(now_info, timeZoneOffset_sec, dst, time_add_hrs, lat_deg, lon_deg,pp_sun) {                    

        lon_deg = -lon_deg; //Meeus uses West longitudes as positive - this is to correct for that
        //deBug("long(MEEUS),UT,TZ,dst", [lon_deg.format("%.2f"), lat_deg.format("%.2f"), timeZoneOffset_sec/3600, dst]);
        

        //var jd = time_add_hrs /24.0f + gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, 0, 0, 0);

        //NOTE: UT/timezone offset must be SUBTRACTED from the time to get the correct time in GMT in this context.
        //Instead we'll use the version in functions.mc, which has this correctly accounted for already.
        //var jd = gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, now_info.hour+ time_add_hrs + dst, now_info.min, -timeZoneOffset_sec);
        var jd = f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour + time_add_hrs, now_info.min, timeZoneOffset_sec/3600f, dst);

        //deBug("JD: ", [jd, now_info.year, now_info.month, now_info.day,now_info.hour + time_add_hrs, now_info.min, timeZoneOffset_sec, dst, time_add_hrs]);
        //var obliq_rad= obliquityEcliptic_rad (now_info.year, now_info.month, now_info.day + time_add_hrs, now_info.hour, now_info.min, timeZoneOffset_sec/3600.0, dst);
        //var obliq_deg = Math.toDegrees(obliq_rad);

        var obliq_deg = f.calc_obliq1_deg (now_info, time_add_hrs, timeZoneOffset_sec, dst);
        var obliq_rad = Math.toRadians(obliq_deg);

        //deBug("long(MEEUS),UT,TZ,dst", [lon_deg, lat_deg, timeZoneOffset_sec/3600, dst, time_add_hrs, time_add_hrs/24.0f, jd]);

        //System.println ("JD: " + jd); 

        //get ra & dec for sun from VSOP87a
        //var ra = 0;
        //var dec = 0;

        var sun_RD = pp_sun;//radec = sunPosition(jd);

        sun_RD[0] = equatorialLong2eclipticLong_deg(sun_RD[0], obliq_deg);

        //return is: [Math.toDegrees(l), Math.toDegrees(t2), r];//lat, lon, r


        if (pp_sun == null ) {
            var sun_radec = planetCoord (now_info, timeZoneOffset_sec, dst, time_add_hrs, :ecliptic_latlon, ["Sun"]);

            //System.println("sun_radec(I): " + (pp_sun[0]) + " " + (pp_sun[1]));
            sun_RD = sun_radec["Sun"];
        }
        //System.println("sun_radec: " + (sun_RD));

        var ret = {};


        //var jd_mid = gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, 0,0,0);

        var jd_mid = f.julianDate (now_info.year, now_info.month, now_info.day + Math.floor((time_add_hrs + now_info.hour)/24.0), 0,0,0,0);

        //Greenwhich mean sidereal time @ midnight of today
        var gmst_mid_deg=f.normalize(GMST_deg(Math.floor(jd_mid)+.5));
        //deBug("gmst: ", [gmst, jd, Math.floor(jd)+.5]);
        //ret.put(:GMST_MID_HR, gmst_mid_deg/15.0);
        //deBug("gmst, jd : ", [gmst_mid_deg, jd]);
        //today's solar transit time in GMT
        var transit_GMT_DAY=f.normalize(sun_RD[0] + lon_deg - gmst_mid_deg)/360.0;
        //ret.put(:TRANSIT_GMT_HR, transit_GMT_DAY*24.0);
        //var transit_GMT_toeclip_day = transit_GMT_DAY*Math.PI*2.0;
        //deBug("transit: ", [transit_GMT_DAY*24.0]);

        var gmst_now_deg = f.normalize(GMST_deg(jd));
        var lmst_now_hr = f.normalize((gmst_now_deg - lon_deg)) / 15.0;
        //ret.put(:GMST_NOW_HR, [gmst_now_deg/15.0]);
        //ret.put(:LMST_NOW_HR, [lmst_now_hr]);
        //deBug("GNMST_MID_HR, GNMST_NOW_HR, LMST_HR, JD: ", [gmst_mid_deg/15.0, gmst_now_deg/15.0, lmst_now_hr, lmst_now_hr*15.0,jd]);

        var tz_add = (timeZoneOffset_sec/3600.0f) + dst;
        //ret.put (:NOON,  constrain(transit_GMT_toeclip_day + tz_add/24.0) * 24.0);


        //[0] = equatorial longitude of the Sun at noon local time
        //[1] = ecliptical long of Sun @ noon local time
        ret.put (:NOON,  [
            constrain(transit_GMT_DAY + tz_add/24.0) * 24.0,
            //constrain(transit_GMT_toeclip_day + tz_add/24.0) * 24.0,
            ]);

        //f.deBug("NOON,tz: ", [constrain(transit_GMT_DAY + tz_add/24.0) * 24.0, tz_add]);


    

        



        //Now all the sun events for today
        for (var i = 0; i<sunEventData.size();i++) {

            
            var kys = sunEventData.keys();        


            var ky = kys[i];

            //if (ky == :NOON ) { continue;}
            if (ret.hasKey(ky) ) { continue;}

            //result in hrs GMT
            //rise & set - in hours GMT
            var sun_info = getRiseSet_hr(jd,
                sunEventData[ky], Math.toRadians(lat_deg), 
                Math.toRadians(lon_deg),
                Math.toRadians(sun_RD[0]),
                Math.toRadians(sun_RD[1]),
                transit_GMT_DAY, obliq_rad); 


            //System.println("sunrise/sets " + tz_add + timeZoneOffset_sec + " " + dst);
            /*var s1_hr = sun_info[0]; //equatorial times
            var s2_hr = sun_info[1];
            var s3_hr = sun_info[4]; //ecliptic times...
            var s4_hr = sun_info[5];*/
            //var s = {};
            //deBug("sun_info", sun_info);
            if (sun_info!=null && sun_info[1] != null) { //if one is null all are
                //s1_hr = f.mod ((s1_hr + tz_add) , 24);
                //s2_hr = f.mod ( (s2_hr + tz_add), 24);
                for (var j =  0; j<2; j++) {
                    sun_info[j] = f.mod ((sun_info[j] + tz_add) , 24);
                }
            } 
            
            ret.put (ky, sun_info);

            /*
            var jd_rise = jd_mid + (s1_hr + tz_add);
            var  jd_set = jd_mid + (s2_hr + tz_add);
            var lmst_rise_deg = f.normalize( GMST_deg(jd_rise) - lon_deg );
            var lmst_set_deg = f.normalize( GMST_deg(jd_set) - lon_deg );
            var riseIntEclipticHorizonPoints_rad = intersectionPointsEclipticHorizon_rad(Math.toRadians(lat_deg), Math.toRadians(lmst_rise_deg), obliq_rad);
            var setIntEclipticHorizonPoints_rad = intersectionPointsEclipticHorizon_rad(Math.toRadians(lat_deg), Math.toRadians(lmst_set_deg), obliq_rad);


            //[0,1] equatorial rise/set times
            //[2,3] ecliptic rise/set times
            ret.put (ky, [s1_hr, s2_hr, 
                (270 - Math.toDegrees(riseIntEclipticHorizonPoints_rad[1]))/15.0,
                (270 - Math.toDegrees(setIntEclipticHorizonPoints_rad[1]))/15.0,
            ]);
            //deBug(sevent_names[ky] + ": ", [s1_hr, s2_hr]);
            */



            //System.println("sunrise/sets " + sun_info + " " + ky) ;
            // if (ky == :HORIZON) { System.println("sunrise/sets HORIZON: " + sun_info + " " + ky) ;}
            
        }

        //Get info for all four points of the ecliptic 
        //for this date & time

        //THIS WORKS but we are not using it for now
            
        /*
        //for (var rra_deg = 0; rra_deg<360;rra_deg += 90) {
        for (var rra_deg = 0; rra_deg<90;rra_deg += 90) { //only need  the 0,0/ORIGIN point for now, not all 4 ecliptic points
            var ddecl_rad = 0;
            if (rra_deg == 90) { ddecl_rad = obliq_rad;}
            if (rra_deg == 270) { ddecl_rad = obliq_rad;}
                //winter solstic RA 0 DECL 0
            //winter solstic RA 0 DECL 0
            var trans_ecliptic_DAY = f.normalize(rra_deg + lon_deg - gmst_mid_deg)/360.0;
            var sun_info = getRiseSet_hr(jd,
                sunEventData[:HORIZON], Math.toRadians(lat_deg), 
                Math.toRadians(lon_deg),
                Math.toRadians(rra_deg),
                ddecl_rad,
                trans_ecliptic_DAY, 
                //0.5, 
                obliq_rad);//Note that ECLIPTIC ONLY just set the time to 12:00 GMT, we are interested in the "straddle" not the specific time of rise for each of these.
        
            var s1_hr =null; //equatorial/RA/Decl
            var s2_hr =null;
            //deBug("sun_riseECP", sun_info);
            if (sun_info != null) {
                s1_hr = sun_info[0]; //equatorial/RA/Decl
                s2_hr = sun_info[1];
            }
            //var s1_hr = sun_info[4]; //ecliptic...
            //var s2_hr = sun_info[5];

            if (sun_info!=null && sun_info[1] != null) { //if one is null both are
                s1_hr = f.mod ((s1_hr + tz_add) , 24);
                s2_hr = f.mod ( (s2_hr + tz_add), 24);
            }     

            if (rra_deg==0) {
            */    

            /***********************************************************************
            /*
            /* INTERSECTION OF ECLIPTIC AND HORIZON FOR HORIZON_DRAWING PURPOSES
            /*
            /***********************************************************************/
                //var abeH = angleBetweenEclipticAndHorizon_rad(Math.toRadians(lat_deg), Math.toRadians(lmst_now_hr*15), obliq_rad);
                var intsectionEclipticHorizonPoints_rad = intersectionPointsEclipticHorizon_rad(Math.toRadians(lat_deg), Math.toRadians(f.normalize(lmst_now_hr*15)), obliq_rad);
                //deBug("angleBetweenEclipticAndHorizon: ", [abeH, ipEH]);
                //deBug("abeH, ipEH: ", [abeH, ipEH]);
                ret.put(:ECLIP_HORIZON, intsectionEclipticHorizonPoints_rad); //add angle & intersection point to the return objec
            
        /*    }

            ret.put ("Ecliptic"+rra_deg, [s1_hr, s2_hr]);
            //deBug("Ecliptic" + rra_deg + ": ", [s1_hr, s2_hr]);

        }*/

        /*System.println("sunrise/sets " + ret);*/

            /*
            //DEBUG PRINT ALL VALUES
            for (var i = 0; i<sunEventData.size();i++) {

                
                var kys = sunEventData.keys();        


                var ky = kys[i];
                System.println("ret: " + ky + " " + ret[ky] + " " + sunEventData[ky]);
            }
            */
            


        return ret;


    }

    //All angles must be in radians
    //Remember Meeus considers West longitudes as positive, the opposite of how everyone else does.
    //Outputs are times in hours GMT (not accounting for daylight saving time)
    //From Meeus Page 101
    function getRiseSet_hr(jd,h0_deg, lat,lon,ra,dec,transit_GMT_DAY, obliq_rad){
        //var h0_deg=-0.8333f; //For Sun
        //var h0_deg=-0.5667; //For stars and planets
        //const h0_deg=0.125   //For Moon; positive value to allow for parallax  from different viewing points around the earth

        ////TEST :
        /*
        ra = Math.toRadians(269.1258593113016);
        dec = Math.toRadians(-23.43291892549076);
        lat = Math.toRadians(39.0089438);
        lon = Math.toRadians(-94.4400866);
        jd = 2460664.5;
        */
        //REsult should be: 
        /*Output
            Rise:	07:35:13
            Transit:	12:17:58
            Set:	17:00:44
            or Rise=.316122
            Transit: .51247685 (local time) / .762477 (UTC)
        */


        //deBug("getRiseSet_hr: ", [jd,h0_deg, lat,lon,ra,dec]);
        //deBug("getRiseSet_hr: ", [jd,h0_deg, Math.toDegrees(lat),Math.toDegrees(lon),Math.toDegrees(ra),Math.toDegrees(dec)]);

    

        if (lat == 0) {lat = 0.0000001;} //to avoid divide by zero
        if (dec == 0) {dec = 0.0000001;} //to avoid divide by zero
        var cosH=(Math.sin(h0_deg*Math.PI/180.0)-Math.sin(lat)*Math.sin(dec)) / (Math.cos(lat)*Math.cos(dec));
        //if (cosH>1 || cosH<-1) {return null;}
        var H0_deg = 0;
        if (cosH<-1) {H0_deg = 179.97;}  //cosH> 1 means, it's up all day long; <-1 means never rises at all
        else if (cosH>1) {return null;} //easiest way to handle no rise at all (if you return 0 it is hard to distinguish from 24 hrs)
        else if (cosH>= -1) {H0_deg=Math.acos(cosH)*180.0/Math.PI;}




        //deBug("transit: ", [transit, Math.toDegrees(ra), Math.toDegrees(lon), gmst]);
        var rise=constrain(transit_GMT_DAY-(H0_deg/360.0)) * 24.0;
        var set=constrain(transit_GMT_DAY+(H0_deg/360.0)) * 24.0;

        //System.println("transit (result/UTC): " + constrain(transit));

        //var ret = [constrain(transit_GMT_DAY)*24.0,constrain(rise)*24.0,constrain(set)*24.0];

        /*var eclip_long_rad = Math.atan2(Math.tan (H0_deg), Math.cos(obliq_rad));
        var eclip_long_deg = Math.toDegrees(eclip_long_rad);

        var ecl_rise_day=transit_GMT_DAY-(eclip_long_deg/360.0);
        var ecl_set_day=transit_GMT_DAY+(eclip_long_deg/360.0);

        var rise_eclip_hr = constrain(Math.atan2(Math.tan (rise/24.0*2*Math.PI), Math.cos(obliq_rad))/2.0/Math.PI) * 24.0;
        if ((rise-rise_eclip_hr).abs() > 6.0) { rise_eclip_hr += 12.0;}

        var set_eclip_hr = constrain(Math.atan2(Math.tan (set/24.0*2*Math.PI), Math.cos(obliq_rad))/2.0/Math.PI) * 24.0;
        deBug("setchr", set_eclip_hr);
        if ((set - set_eclip_hr).abs() > 6.0) {set_eclip_hr += 12.0;}
        deBug("setchr2", set_eclip_hr);
        */
        //rise & set times converted to distances from the origin along the ecliptic (rather than along the celestial equator)
        //var ecl_rise_day = ( constrain(transit_GMT_DAY + equatorialLong2eclipticLong_rad (Math.toRadians(-H0_deg), obliq_rad)/2.0/Math.PI) ) * 24.0;
        //var ecl_set_day = (constrain( transit_GMT_DAY + equatorialLong2eclipticLong_rad (Math.toRadians(H0_deg), obliq_rad)/2.0/Math.PI) ) * 24.0;

        //var ret = [rise,set, ecl_rise_day, ecl_set_day];
        var ret = [rise,set];

        //System.println("transit (results/UTC): " + H0_deg + " " + ret);
        return ret;
        //returns transit in DAYS....
        
        //return constrain(transit);
    }



    /*
    function exampleMeeus(){
        var jd=2447240.5;
        var lat=Math.toRadians(42.3333);
        var lon=Math.toRadians(-71.08333);
        var gmst=Math.toRadians(177.74208);
        var ra=Math.toRadians(41.73129);
        var dec=Math.toRadians(18.44092);

        //var r=getRiseSet_hr(jd,-.833333,lat,lon,ra,dec);

        //System.println("Transit (hr): "+ r) ;


    }
    */

    /*
    function sunPosition2(jd){
        vspo_2_J2000([0,0,0], earth, true, :ecliptic_latlon, ["Sun"]);
    }

    function sunPosition(jd)	{
        const torad=Math.PI/180.0;
        const n=jd-2451545.0;
        let L=(280.460+0.9856474*n)%360;
        let g=((375.528+.9856003*n)%360)*torad;
        if(L<0){L+=360;}
        if(g<0){g+=Math.PI*2.0;}

        const lamba=(L+1.915*Math.sin(g)+0.020*Math.sin(2*g))*torad;
        const beta=0.0;
        const eps=(23.439-0.0000004*n)*torad;
        let ra=Math.atan2(Math.cos(eps)*Math.sin(lamba),Math.cos(lamba));
        const dec=Math.asin(Math.sin(eps)*Math.sin(lamba));
        if(ra<0){ra+=Math.PI*2;}
        return [ra/torad/15.0,dec/torad];
    }	

    //Special "Math.floor()" function used by dateToJulianDate()
    function INT(d){
        if(d>0){
            return Math.floor(d);
        }
        return Math.floor(d)-1;
    }
    */

    //Special "Math.floor()" function used by dateToJulianDate()
    function INT(d){
        if(d>0){
            return Math.floor(d);
        }
        if(d==Math.floor(d)){
            return d;
        }
        return Math.floor(d)-1;
    }

    /*
    function gregorianDateToJulianDate(year, month, day, hour, min, sec)as Lang.double {

        var isGregorian=true;
        if(year<1582 || (year == 1582 && (month < 10 || (month==10 && day < 5)))){
            isGregorian=false;
        }

        if (month < 3){
            year = year - 1;
            month = month + 12;
        }

        var b = 0;
        if (isGregorian){
        var a = INT(year / 100.0d);
            b = 2 - a + INT(a / 4.0d);
            deBug("JD: a,b: ", [a,b]);
        }
        var jd = 0.0d;    
        jd=INT(365.25d * (year + 4716d)) + INT(30.6001d * (month + 1)) + day + b - 1524.5d;
        deBug("JD: jd: ", [jd, 365.25d * (year + 4716d),INT(365.25d * (year + 4716d)), 30.6001d * (month + 1),INT(30.6001d * (month + 1)), day, b]);
        jd = jd.toDouble();

        deBug("JD2: jd: ", [jd]);

        jd+=hour/24.0d;
        jd+=min/24.0d/60.0d;
        jd+=sec/24.0d/60.0d/60.0d;
        deBug("JD3: jd: ", [jd, hour, min, sec]);
        return jd;
    }
    */

    /*
    function gregorianDateToJulianDate(year, month, day, hour, min, sec){
        var isGregorian=true;
        if(year<1582 || (year == 1582 && (month < 10 || (month==10 && day < 5)))){
            isGregorian=false;
        }

        if (month < 3){
            year = year - 1;
            month = month + 12;
        }

        let b = 0;
        if (isGregorian){
        let a = INT(year / 100.0);
            b = 2 - a + INT(a / 4.0);
        }

        let jd=INT(365.25 * (year + 4716)) + INT(30.6001 * (month + 1)) + day + b - 1524.5;
        jd+=hour/24.0;
        jd+=min/24.0/60.0;
        jd+=sec/24.0/60.0/60.0;
        return jd;
    }
    */


    /*

    function sunPosition(jd)	{
        const torad=Math.PI/180.0;
        const n=jd-2451545.0;
        let L=(280.460+0.9856474*n)%360;
        let g=((375.528+.9856003*n)%360)*torad;
        if(L<0){L+=360;}
        if(g<0){g+=Math.PI*2.0;}

        const lamba=(L+1.915*Math.sin(g)+0.020*Math.sin(2*g))*torad;
        const beta=0.0;
        const eps=(23.439-0.0000004*n)*torad;
        let ra=Math.atan2(Math.cos(eps)*Math.sin(lamba),Math.cos(lamba));
        const dec=Math.asin(Math.sin(eps)*Math.sin(lamba));
        if(ra<0){ra+=Math.PI*2;}
        return [ra/torad/15.0,dec/torad];
    }
    RA = 0h, Dec = 0° is the vernal equinox point
    RA = 6h, Dec = +23.5° is the summer solstice
    RA = 12h, Dec = 0° is the autumnal equinox
    RA = 18h, Dec = -23.5° is the winter solstice
    


    */
}
    /***************************************************************************
    //RETURNS ANGLE BETWEEN ECLIPTIC AND HORIZON AT CURRENT LATITUDE & TIME
    //
    //https://www.celestialprogramming.com/snippets/angleBetweenEclipticAndHorizon.html
    //Greg Miller (gmiller@gregmiller.net) 2022
    //Released as public domain
    //www.celestialprogramming.com

    //All angles are input and output in radians
    /***************************************************************************/
    (:glance)
    function angleBetweenEclipticAndHorizon_rad(lat_rad,sidereal_rad,obliquity_rad){
        //Meeus 14.3

        //law of cosines (sin(latitude) because it is the  complement of the angle we are looking for, so cos(angle) = sin(complement of the angle))   
        var ret = Math.acos(Math.cos(obliquity_rad.toDouble())*Math.sin(lat_rad.toDouble()) - Math.sin(obliquity_rad.toDouble())*Math.cos(lat_rad.toDouble())*Math.sin(sidereal_rad.toDouble()));
        //deBug("angleBetweenEclipticAndHorizon: aOLS ", [Math.toDegrees(ret), Math.toDegrees(obliquity_rad), Math.toDegrees(lat_rad), Math.toDegrees(sidereal_rad)]);
        return ret;
    }

    /***************************************************************************
    //RETURNS CRITICAL POINTS & ANGLE BETWEEN ECLIPTIC AND HORIZON AT CURRENT LATITUDE & TIME
    //
    // aEH_rad = angle between ecliptic and horizon
    // horEHint_rad = horizon great circle distance from equator to ecliptic
    // eclEHint_rad = ecliptic great circle distance from vernal equinox to horizon
    // All angles input & output are RADIANS
    //
    /**************************************************************************/

    (:glance)
    function intersectionPointsEclipticHorizon_rad (lat_rad, sidereal_rad, obliquity_rad) {

        //f.deBug("IPEHR", [lat_rad, sidereal_rad, obliquity_rad]);

        ///below is something the AI suggested but I'm not 100% clear on what it is supposed to be calculating.
        //Meeus 14.3
        /*var a = Math.cos(obliquity)*Math.sin(lat) - Math.sin(obliquity)*Math.cos(lat)*Math.sin(sidereal);
        var b = Math.cos(lat)*Math.cos(sidereal);
        var c = Math.cos(lat)*Math.sin(obliquity) + Math.sin(lat)*Math.cos(obliquity)*Math.sin(sidereal);
        var d = Math.atan2(b,a);
        var e = Math.asin(c);
        deBug("intersectionPointEclipticHorizon: ", [a,b,c,d,e]);
        return [d,e];*/
        ///END AI suggestion

        //for whatever ?!? reason, eclEHint4 works whenever there is a sunrise/sunset, and eclEHint2 works when the sun is always up or always below the horizon, like above arctic circle in high summer or winter
        var use_eclEHint2 = false;
        //if (sunrise_hrs== null || sunrise_hrs[0] == null || (sunrise_hrs[1]-sunrise_hrs[0]).abs() < 0.15) { use_eclEHint2 = true;}
        //use_eclEHint2 = false;
        if (1.5708 - lat_rad.abs()< obliquity_rad) {use_eclEHint2 = true;} //for whatever reason the  two equations seem to work above & below the latitude of the arctic circle/ 90 - obliq of the ecliptic.

        var aEH_rad = angleBetweenEclipticAndHorizon_rad(lat_rad,sidereal_rad,obliquity_rad);

        // horEH is the distance along the horizon great circle from the intersection with the equator great circle
        // to the intersection with the ecliptic great circle.  It is measured in radians.
        var horEHint_rad  = 0d;  //not sure what to return here,  Inf or null maybe.  This should represent the case where the angle is zero or 180 deg and thus  the two circles are coincident.  So 0 probably works best.

        //law of sines:
        if (Math.sin(aEH_rad) != 0) {
            //horEHint_rad = Math.asin( Math.sin(Math.PI/2.0)/ Math.sin(aEH_rad)*Math.sin(obliquity_rad));
            var intm = Math.sin(sidereal_rad.toDouble() - Math.PI/2.0)/ Math.sin(aEH_rad.toDouble())*Math.sin(obliquity_rad.toDouble());
            //deBug("horEHint", [Math.toDegrees(sidereal_rad.toDouble()), Math.toDegrees(aEH_rad.toDouble()), intm]);
            if (intm>1 || intm<-1) {horEHint_rad = Math.PI/2.0;}
            else {
                horEHint_rad = Math.asin(intm);
            }

            /*var q1 = quadrant_rad(horEHint_rad);
            var q2 = quadrant_rad(sidereal_rad - Math.PI/2.0);
            if (q1==q2) {horEHint_rad = Math.PI - horEHint_rad;}
            deBug ("horEHint_rad", [Math.toDegrees(horEHint_rad),Math.toDegrees(sidereal_rad.toDouble() - Math.PI/2.0), Math.toDegrees(aEH_rad), intm, q1, q2]); */
        }
        
        var eclEHint_rad = 0;
        if (use_eclEHint2) {

                // eclEH is the distance along the ecliptic great circle from the intersection with the equator great circle,  ie the vernal equinox, to the intersection with the horizon great circle.  It is measured in radians. (Because of symmetry it is also the angle from the fall equinox to the intersection point. But the Vernal Eq is 0,0 the origin point of the system.)
                
                //This one works great for everything above the arctic circle/when sun is always up
                var eclEHint2_rad = 0; //alternate calculation, it's equal. O/horEHint
                //var horEHint_copy_rad = horEHint_rad;
                //if (Math.sin(aEH_rad) != 0) {

                //var add_rad = 0;
                //if (lat_deg < 0) {add_rad = Math.PI;}

                var intm = Math.sin(horEHint_rad)/Math.sin(obliquity_rad)*Math.cos(lat_rad);
                if (intm>=-1 && intm <=1) {
                    if (lat_rad > 0) {eclEHint2_rad = - Math.asin(intm);}
                    else {eclEHint2_rad = Math.PI +  Math.asin(intm);}
                } else {use_eclEHint2 = false;}
                
                eclEHint_rad = eclEHint2_rad;
                //deBug("intersectionPointEclipticHorizon aoLs TWO: ", [Math.toDegrees(horEHint_rad), Math.toDegrees(eclEHint2_rad),  Math.toDegrees(aEH_rad), Math.toDegrees(sidereal_rad), intm]);
        }
                
                


        // eclEH is the distance along the ecliptic great circle from the intersection with the equator great circle,  ie the vernal equinox, to the intersection with the horizon great circle.  It is measured in radians. (Because of symmetry it is also the angle from the fall equinox to the intersection point. But the Vernal Eq is 0,0 the origin point of the system.)

        /*
        var eclEHint_rad = 0; //similarly, 0 is probably the best choice here for  the case sin() = 0. That is the situation where the horizon & ecliptic coincide.
    if (Math.sin(aEH_rad) != 0) {
            var sid2 = sidereal_rad;
            
            //if (sid2<=Math.PI && sid2 <= Math.toRadians(200)) {sid2 -= Math.PI;}
            //if (sid2<= Math.toRadians(330) && sid2 <= 2.0*Math.PI) {sid2 -= Math.PI;} 

            var hor_sid_rad = sidereal_rad - Math.PI/2.0;
            var add180 = 0;

            if (hor_sid_rad> -Math.PI/2.0 + Math.toRadians(20) && hor_sid_rad < Math.PI/2.0 + Math.toRadians(20)) {
                hor_sid_rad += Math.PI;
                add180 = Math.PI;}
                else if (hor_sid_rad>= 3* Math.PI/2.0 && hor_sid_rad < 3.0*Math.PI/2.0 + Math.toRadians(20)) {
                    hor_sid_rad -= Math.PI;
                    add180 = Math.PI;
                }else if (hor_sid_rad>= Math.PI/2.0 - Math.toRadians(20) && hor_sid_rad < Math.PI/2.0) {
                    hor_sid_rad -= Math.PI;
                    add180 = Math.PI;
                }

            var intm = Math.sin(hor_sid_rad)/ Math.sin(aEH_rad)*Math.cos(lat_rad);
            deBug("intersectionPointEclipticHorizon MUP: ", [Math.sin(sidereal_rad - Math.PI/2.0), Math.sin(aEH_rad), Math.cos(lat_rad), intm, Math.toDegrees(sidereal_rad)]);
            if (intm>1 || intm<-1) {eclEHint_rad = Math.PI/2.0;}
            else {
                
                eclEHint_rad = Math.asin(intm) + add180;
                //if (hor_sid_rad<0) {eclEHint_rad = Math.PI - eclEHint_rad;}
            }
        }

        */


        //the law of sines approach gives the correct answer but then somehow chooses the wrong branch starting at 90 + angle of obliquity and other such random angles.  So it's hard to work with.
        /*
        var eclEHint_rad = 0; //similarly, 0 is probably the best choice here for  the case sin() = 0. That is the situation where the horizon & ecliptic coincide.
        var eclEHint3_rad = 0;
        if (Math.sin(aEH_rad) != 0) {
            var sid2 = sidereal_rad;
            var adder = 0;
            if (sid2<=Math.PI + obliquity_rad || sid2 >= Math.PI * 2.0 - obliquity_rad) {sid2 -= Math.PI; adder = Math.PI;}

            var hor_sid_rad = sid2 - Math.PI/2.0;

            var intm = Math.sin(hor_sid_rad)/ Math.sin(aEH_rad)*Math.cos(lat_rad);
            deBug("intersectionPointEclipticHorizon MUP: ", [Math.sin(sidereal_rad - Math.PI/2.0), Math.sin(aEH_rad), Math.cos(lat_rad), intm, Math.toDegrees(sidereal_rad)]);
            if (intm>1 || intm<-1) {eclEHint_rad = Math.PI/2.0;}
            else {
                
                eclEHint_rad = Math.asin(intm) + adder;
                //if (hor_sid_rad<0) {eclEHint_rad = Math.PI - eclEHint_rad;}
            }

            var y = Math.sin(hor_sid_rad) * Math.cos(lat_rad);
            var x = Math.sin(aEH_rad);
            eclEHint3_rad =Math.atan2(y,  x);

            deBug("IntersectionTAN: ", [Math.toDegrees(eclEHint_rad), Math.toDegrees(eclEHint3_rad), Math.toDegrees(hor_sid_rad), x, y]);
            
        }
        */

        if (!use_eclEHint2) {

            //The law of cosines approach seems to work better than the law of sines approach just because it is more sensible in the areas where it gives the right result vs the negative or complement of the angle result. It works for -90 to 90 degrees and for 90 to 270 you just need to flip the sign of the result. (it would probably work to subtract 180 degrees, as well.) 
            //if (Math.toDegrees(sidereal_rad)>201.7 && Math.toDegrees(sidereal_rad)<339) {horEHint_rad = Math.PI - horEHint_rad ;}//@+81 degrees
            //if (Math.toDegrees(sidereal_rad)>26.8 && Math.toDegrees(sidereal_rad)<153.9 ) {horEHint_rad = Math.PI - horEHint_rad ;}//@-79 degrees
            //if (Math.toDegrees(sidereal_rad)>45.7 && Math.toDegrees(sidereal_rad)<135 ) {horEHint_rad = Math.PI - horEHint_rad ;} //@-73 degrees
            var eclEHint4_rad = 0d;
            var intm = Math.cos(sidereal_rad.toDouble() - Math.PI/2.0d) * Math.cos(horEHint_rad.toDouble()) + Math.sin(sidereal_rad.toDouble() - Math.PI/2.0d) * Math.sin(horEHint_rad.toDouble()) * Math.sin(lat_rad.toDouble());
            if (intm>1 || intm<-1) {eclEHint4_rad = Math.PI - sidereal_rad;} //In case >1 or <-1 that is the situation where there is not a solution; this shouldn't happen as great circles always intersect at two points OR all points.
            else {
                eclEHint4_rad = Math.acos(intm);
                if (sidereal_rad < 3*Math.PI/2.0d && sidereal_rad > Math.PI/2.0d) {eclEHint4_rad = -eclEHint4_rad;} // the cosine formula returns the negative of the angle when the origin  Rad/Dec=0,0 is below the horizon, so we just flip signs.
                //eclEHint4_rad += Math.PI;
                
            }
            eclEHint_rad = eclEHint4_rad;
            //deBug("intersectionPointEclipticHorizon aoLs FOUR: ", [Math.toDegrees(horEHint_rad), Math.toDegrees(eclEHint4_rad),  Math.toDegrees(aEH_rad), Math.toDegrees(sidereal_rad), intm]);
        }

        /*
        var eclEHint5_rad = 0d;
        var intm2 = Math.cos(sidereal_rad.toDouble() - Math.PI/2.0d) * Math.cos(Math.PI - horEHint_rad.toDouble()) + Math.sin(sidereal_rad.toDouble() - Math.PI/2.0d) * Math.sin(Math.PI - horEHint_rad.toDouble()) * Math.sin(lat_rad.toDouble());
        if (intm2>1 || intm2<-1) {eclEHint5_rad = Math.PI - sidereal_rad;} //In case >1 or <-1 that is the situation where there is not a solution; this shouldn't happen as great circles always intersect at two points OR all points.
        else {
            eclEHint5_rad = Math.acos(intm2);
            if (sidereal_rad < 3*Math.PI/2.0d && sidereal_rad > Math.PI/2.0d) {eclEHint5_rad = -eclEHint5_rad;} // the cosine formula returns the negative of the angle when the origin  Rad/Dec=0,0 is below the horizon, so we just flip signs.
            //eclEHint4_rad += Math.PI;
            
        }

        //if (eclEHint5_rad.abs() < eclEHint4_rad.abs()) {eclEHint4_rad = eclEHint5_rad;}
        */
        



        //AI suggested using atan2 instead, but it doesn't work
        //eclEHint_rad = Math.atan2(Math.sin(sidereal_rad - Math.PI/2.0) * Math.cos(lat_rad), Math.sin(aEH_rad));
        //test_angleBetweenEclipticAndHorizon_rad();

        //deBug("intersectionPointEclipticHorizon aoLs: ", [Math.toDegrees(horEHint_rad), Math.toDegrees(eclEHint4_rad), Math.toDegrees(eclEHint2_rad),  Math.toDegrees(aEH_rad), Math.toDegrees(sidereal_rad), intm]);
        //return  [eclEHint_rad, horEHint_rad];
        //return [horEHint_rad.toFloat(), eclEHint_rad.toFloat(), aEH_rad.toFloat()];
        
        return eclEHint_rad.toFloat();

    }


(:glance)
function equatorialLong2eclipticLong_rad (H0_rad, obliq_rad) {

    //spherical Law of Tangents, bAcB case:
    //   (CT3) cosc * cosA =  cotb * sinc − cotB * sinA (bAcB)
    //X is the distance along the ecliptic from the origin to the setting point of the object (sun)
    //We know H0, which is the distance along the equator from the origin to the point where the object sets.
    // obliq_rad is the angle between the ecliptic and the equator.
    //The other angle of the triangle is a right angle (from say 5:45 RA on the equator to the point where that intersects both the horizon & the ecliptic at the moment this object is setting)'
    //cot(X) = (Math.cos (H0_rad)*Math.cos (obliq_rad) + Math.atan(90deg)*Math.sin(obliq_rad)) / math.sin(H0_rad)
    //atan(90 degrees) = 1;
    //var X = acot(intmd);
    //var X = Math.atan2(math.sin(H0_rad), (Math.cos (H0_rad)*Math.cos (obliq_rad) + 0*Math.sin(obliq_rad)));

    var X = Math.atan2(Math.sin(H0_rad), (Math.cos (H0_rad)*Math.cos (obliq_rad)));
    //deBug("eclipSetfromEq: X", [Math.toDegrees(X)]);
    return X;

}

(:glance)
function equatorialLong2eclipticLong_deg (H0_deg, obliq_deg) {
    return Math.toDegrees(equatorialLong2eclipticLong_rad(Math.toRadians(H0_deg), Math.toRadians(obliq_deg)));
}

//Greenwhich mean sidreal time from Meeus page 88 eq 12.4
//Input is julian date, does not have to be 0h
//Output is angle in degrees
(:glance)
function GMST_deg(jd){
    var T=(jd-2451545.0d)/36525.0d;
    var st=280.46061837d+360.98564736629d*(jd-2451545.0d)+0.000387933d*T*T - T*T*T/38710000.0d;
    //deBug("GMST1: ", [st, jd, T]);
    //st=mod(st,360);
    //if(st<0){st+=360;}
    st = f.normalize(st);
    //deBug("GMST2: ", [st, jd, T]);

    return st;
    //return st*Math.PI/180.0;
}


    

/*
//2024/12 - tested, it works
function test_angleBetweenEclipticAndHorizon_rad(){
    var r=Math.PI/180;
    var eps=23.44*r;    
    var lat=51*r;
    var sidereal=75*r;

    var d=angleBetweenEclipticAndHorizon_rad(lat,sidereal,eps)*180/Math.PI;
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Expected: "+62, []);
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Computed: ", [f.normalize(d)]);
    
    eps=23.44*r;
    lat=38*r;
    sidereal=112.5*r;

    d=angleBetweenEclipticAndHorizon_rad(lat,sidereal,eps)*180/Math.PI;
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Expected: 74.0228155356797°", []);
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Computed: ", [f.normalize(d)]);
    
    } 
    */
