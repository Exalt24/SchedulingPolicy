import 'package:flutter/material.dart';
import 'package:scheduling_os/scheduling/FCFS.dart';
import 'package:scheduling_os/scheduling/SJF.dart';
import 'package:scheduling_os/scheduling/priority.dart';
import 'package:scheduling_os/scheduling/roundRobin.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print('${size.width} , ${size.height}');
    
    return Scaffold(
      body: Stack(
        //fit: StackFit.expand,
        children: [
          // Background Image
          Center(
            child: Container(
              width: size.width,
              height: size.height, 
              color: const Color.fromRGBO(237, 140, 0, 1),
              child: Image.asset(
                'assets/HomePageBackground.png', // Replace with your image path
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
      
          Container(
            padding: const EdgeInsets.all(16),
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Container(
                  width: size.width,
                  alignment: Alignment.center,
                  child: const Text(
                    'Choose the Scheduling Policy',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kavoon',
                      color:Colors.white
                    ),
                  ),
                ),
                const SizedBox(height:24),
                Container( 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //FCFS
                      InkWell(
                        onTap: (){
                          Navigator.push( 
                          context, 
                          MaterialPageRoute( 
                              builder: (context) => 
                                const FCFS())); 
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: size.width * 0.2,
                          height: size.height * 0.68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [                
                                Color.fromRGBO(237, 140, 0, 1),
                                Color.fromRGBO(255, 177, 0, 1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(color: Colors.white, width:10)
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/bee.png'),
                              ),
                              const SizedBox(height: 10,),
                              const Text('First-Come, First-Serve',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10,),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text('Processes are executed in the order they arrive, without considering their burst times.',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontFamily: 'Karla'
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ]
                          )
                        ),
                      ),
                      
                      
                      //SSJ
                      InkWell(
                        onTap: (){
                          Navigator.push( 
                          context, 
                          MaterialPageRoute( 
                              builder: (context) => 
                                const SJF())); 
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: size.width * 0.2,
                          height: size.height * 0.68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [                
                                Color.fromRGBO(237, 140, 0, 1),
                                Color.fromRGBO(255, 177, 0, 1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(color: Colors.white, width:10)
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/bee.png'),
                              ),
                              const SizedBox(height: 10,),
                              const Text('Shortest Job First',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10,),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text('The process with the smallest burst time is executed next, aiming to minimize waiting times.',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontFamily: 'Karla'
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ]
                          )
                        ),
                      ),
                      
                      //Priority
                      InkWell(
                        onTap: (){
                          Navigator.push( 
                          context, 
                          MaterialPageRoute( 
                              builder: (context) => 
                                const PrioritySched())); 
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: size.width * 0.2,
                          height: size.height * 0.68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [                
                                Color.fromRGBO(237, 140, 0, 1),
                                Color.fromRGBO(255, 177, 0, 1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(color: Colors.white, width:10)
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/bee.png'),
                              ),
                              const SizedBox(height: 10,),
                              const Text('Priority Scheduling',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10,),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text('Processes are executed based on their priority levels, with higher priority processes given preference.',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontFamily: 'Karla'
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ]
                          )
                        ),
                      ),
                      
                      //Round-Robin
                      InkWell(
                        onTap: (){
                          Navigator.push( 
                          context, 
                          MaterialPageRoute( 
                              builder: (context) => 
                                const RoundRobin())); 
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: size.width * 0.2,
                          height: size.height * 0.68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [                
                                Color.fromRGBO(237, 140, 0, 1),
                                Color.fromRGBO(255, 177, 0, 1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(color: Colors.white, width:10)
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/bee.png'),
                              ),
                              const SizedBox(height: 10,),
                              const Text('Round-Robin',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10,),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text('Processes receive equal time slices for execution, promoting fairness and preventing CPU dominance.',
                                style: TextStyle(
                                    fontSize: 24.5,
                                    color: Colors.white,
                                    fontFamily: 'Karla'
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ]
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]
      ),
    );
  }
}