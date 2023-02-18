import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'constraints.dart' as k;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

   bool isLoaded=false;
   num? temp;
   num? pressure;
   num? humidity;
   num? cover;
  // List description=[];
   String cityname='';
  TextEditingController controller=TextEditingController();

  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
             body: Container(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height,
               decoration: const BoxDecoration(
                 image: DecorationImage(
                     image: AssetImage("images/images.png"),
                     fit: BoxFit.cover),
               ),
                 child:Visibility(
                   visible: isLoaded,
                   child: Padding(
                     padding: const EdgeInsets.only(left:25),
                     child: SingleChildScrollView(
                       child: Column(

                         crossAxisAlignment: CrossAxisAlignment.start,
                         children:  [
                           Container(
                             width: MediaQuery.of(context).size.width*0.85,
                             height: MediaQuery.of(context).size.height*0.07,
                             padding:EdgeInsets.symmetric(
                               horizontal: 10
                             ),
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.all(Radius.circular(20,),)
                             ),
                             child:Center(
                               child: TextFormField(
                                 onFieldSubmitted: (String text){
                                   setState(() {
                                     cityname=text;
                                     getCityWeather(text);
                                     setState(() {
                                       isLoaded=false;
                                     });
                                   });
                                 },
                                 controller: controller,
                                 cursorColor:Colors.white,
                                 style:TextStyle(
                                   fontSize:20,
                                   color: Colors.white.withOpacity(0.7),
                                 ),
                                 decoration:InputDecoration(
                                   hintText: 'Search city',
                                   hintStyle:TextStyle(
                                   color: Colors.white.withOpacity(0.7),
                                 ),
                                   prefixIcon: Icon(
                                     Icons.search_rounded,
                                     size:25,
                                     color: Colors.white,
                                   ),
                                   border:InputBorder.none
                                 )
                               ),
                             )

                           ),


                           SizedBox(
                             height: 80, ),
                              Text(cityname,style: (TextStyle(
                                 fontSize: 30,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w700
                             )),),
                           Text("Saturday,Feb,2021",style: (TextStyle(
                               fontSize:16,
                               color: Colors.white,
                           )),),
                           SizedBox(
                             height:130, ),
                           Padding(
                             padding: EdgeInsets.only(left:39.0),
                             child: Icon(Icons.cloud,
                                 size: 50,
                                 color: Colors.white
                             ),
                           ),
                           Padding(
                             padding: EdgeInsets.only(left:18.0),
                             child: Text('cloud',style: (TextStyle(
                               fontSize:16,
                               color: Colors.white,
                             )),),
                           ),
                           SizedBox(
                             height:10, ),
                           Padding(
                             padding: EdgeInsets.only(left:18.0),
                             child: Text('Pressure:${pressure?.toInt()}hPa',style: (TextStyle(
                                     fontSize:16,
                                     color: Colors.white,
                                 )),),

                           ),
                           Padding(
                             padding: EdgeInsets.only(left:18.0),
                             child: Text('Humidity:${humidity?.toInt()}%',style: (TextStyle(
                               fontSize:16,
                               color: Colors.white,
                             )),),

                           ),
                           SizedBox(
                             height:120, ),
                           Padding(
                             padding: EdgeInsets.only(left:18.0),
                             child: Text('${temp?.toInt()}°C',style: (TextStyle(
                               fontSize:90,
                               color: Colors.white,
                               fontWeight: FontWeight.bold
                             )),),
                           ),

                         ],
                       ),
                     ),
                   ),
                     replacement:Center(
                         child: const CircularProgressIndicator(),
                     )

             )
             ),

        ));
  }
  getCurrentLocation() async {
    var position=await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    if (position!=null) {
      print('lat:${position.latitude},long:${position.longitude}');
      getCurrentCityWeather(position);
    }
    else{
      print("Data Unavailable");
    }

  }

  getCurrentCityWeather(Position pos)async {
    var client = http.Client();
    var uri = '${k.domain}lat=${pos.latitude}&lon=${pos.longitude}&appid=${k
        .apiKey}';
    var url=Uri.parse(uri);
    var response=await client.get(url);
    if(response.statusCode == 200){
      var data=response.body;
      var decodedData=jsonDecode(data);
      print(data);
      updateUI(decodedData);
      setState((){
        isLoaded=true;
      });
    }
    else{
      print(response.statusCode);
    }

  }
  updateUI(var decodedData){
    setState(() {

      if(decodedData == null){
        temp=0;
        pressure=0;
        humidity=0;
        cover=0;
        cityname="Not available";
      //  description=[];
      }else{
        temp=decodedData['main']['temp']-273;//kelvin to degree celcius)-273
        pressure=decodedData['main']['pressure'];
        humidity=decodedData['main']['humidity'];
        cover=decodedData['clouds']['all'];
        cityname=decodedData['name'];
      //  description=decodedData['weather']['description'];
      }
    });
  }
  getCityWeather(String cityname)async{
    var client = http.Client();
    var uri = '${k.domain}q=$cityname&appid=${k
        .apiKey}';
    var url=Uri.parse(uri);
    var response=await client.get(url);
    if(response.statusCode == 200){
      var data=response.body;
      var decodedData=jsonDecode(data);
      print(data);
      updateUI(decodedData);

      setState((){
        isLoaded=true;
      });
    }
    else{
      print(response.statusCode);
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }
}
