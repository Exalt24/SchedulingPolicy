import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scheduling_os/scheduling/Homepage.dart';
import 'package:scheduling_os/scheduling/process.dart';


class FCFS extends StatefulWidget {
  const FCFS({super.key});

  @override
  State<FCFS> createState() => _FCFSState();
}

class _FCFSState extends State<FCFS> {
  List<Process> processes = [];
  int _counter = 0;
  late Timer _timer;
  int processNum =0;
  bool isGenerating = false;
  // bool isRunning = false;
  int TimerCounter =0;
  bool isPaused = true;
  MemoryManager memoryManager = MemoryManager(
    memoryBlocks: List.generate(100, (index) => MemoryBlock(startAddress: index * 10, size: 10)),
    pageSize: 10,
    totalMemory: 1000,
    workingSetSize: 5,
  );

  void generateRandomly(){
    Random random = Random();

    int randomTime = random.nextInt(2) + _counter;

    if(_counter==randomTime){
      generateNewProcess();
    }
  }

  void generateNewProcess() {
    // Generate random values for the new process
    Random random = Random();
    String processId = 'P${processNum+ 1}';
    int arrivalTime = _counter; // Random arrival time between 0 and 99
    int burstTime = random.nextInt(9)+1;
    //int burstTime = 4;
    int memorySize = random.nextInt(99)+1; // Random memory size between 0 and 99
    int priority = random.nextInt(3); // Random priority between 0 and 2
    String status = 'Job Queue';
    List<Pagee> pages = [];

    // Create a new Process object with the generated values
    Process newProcess = Process(processId, arrivalTime, memorySize, priority, burstTime: burstTime, status: status, pages: pages);

    setState(() {
      processNum++;
      processes.add(newProcess);
      // memoryManager.allocateProcess(newProcess);
    });

  }


  void _startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!isPaused) {
      TimerCounter++;

      //change number if want slower
      if (TimerCounter % 2 == 0){
        setState(() {
          _counter++;

          if(isGenerating){
            generateRandomly();
          }

          FirstComeFirstServed(processes, memoryManager);



        });
      }
    }
    });
  }

  void _pauseOrStartTimer(){
    setState(() {
      isPaused = !isPaused;
    });
    if (!isPaused) {
      _startTimer();
    }
  }

  //if manual
  void addCounter(){
    setState(() {
      _counter++;
      FirstComeFirstServed(processes, memoryManager);


    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
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
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: (){
                            Navigator.push( 
                            context, 
                            MaterialPageRoute( 
                                builder: (context) => 
                                   Homepage())); 
                          }, 
                          icon: Icon(Icons.arrow_back, color: Colors.white,)
                        ),
                        Spacer(),
                        Text(
                          'First-Come, First-Serve Scheduling',
                          style: TextStyle(
                            fontFamily: 'Kavoon',
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 50,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: LayoutBuilder(
                    builder: (context,constraints) {
                      double width = constraints.maxWidth;
                      double height = constraints.maxHeight;
                      print('$width, $height');
                      return Container(
                      child:Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 80),
                                Text(
                                  'CPU Time: ${_counter.toString()} s ',
                                  style: TextStyle(color: Colors.white, fontSize: 30),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Add your onPressed logic here
                                        if(_counter==0 && processes.isEmpty)
                                          _startTimer();
                                        generateNewProcess();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.pressed)) {
                                              // Return light blue when pressed
                                              return Colors.orangeAccent;
                                            }
                                            // Return blue when not pressed
                                            return Colors.orange[400]!;
                                          },
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(Size(150, 50)),
                                        shape:
                                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                            side: BorderSide(
                                                width: 2.0,
                                                color: Colors.white), // White border
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Add Random',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: isPaused ? null : () {
                                        // Add your onPressed logic here
                                        if(_counter==0 && processes.isEmpty)
                                          _startTimer();

                                        isGenerating =!isGenerating;
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                          MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return isPaused ? Colors.grey : isGenerating ? Colors.orange[100]! : Colors.orange[400]!;
                                          },
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(Size(150, 50)),
                                        shape:
                                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                            side: BorderSide(
                                                width: 2.0,
                                                color: Colors.white), // White border
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        isGenerating ? 'Stop Generating' : 'Generate',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Add your onPressed logic here
                                        _pauseOrStartTimer();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return isPaused ? Colors.orange[400]! : Colors.orange[100]!;
                                          },
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(Size(150, 50)),
                                        shape:
                                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                            side: BorderSide(
                                                width: 2.0,
                                                color: Colors.white), // White border
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        isPaused ? 'Start' : 'Pause',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 80),
                              ],
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding:EdgeInsets.only(bottom:10, left:250, right:250),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  tableTitle("Process ID"),
                                  tableTitle("Burst Time"),
                                  tableTitle("Arrival Time"),
                                  tableTitle("Memory Size"),
                                  tableTitle("Status"),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: height * 0.78,
                              child: LayoutBuilder(
                                builder: (context, constraints){
                                  double width = constraints.maxWidth;
                                  double height = constraints.maxHeight;
                                  //print('$width, $height');
                                  return Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(

                                        children: processes.map((process)
                                        {

                                          return processContainers(process);
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                }
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  ),
                )
              ],
            ),
          )
        ]
      )
    );
  }

   Widget tableTitle(String title){
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.orange[400],
        border: Border.all(
          color: Colors.white,
          width: 2.0, // Adjust the border width as needed
        ),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontSize: 20),
          child: Text(title),
        ),
      ),
    );
  }

  Widget processContainers (Process process){
    return Padding(
      padding: EdgeInsets.only(bottom:10, left:250, right:250),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          singleProcessContainers(process.processId, process.status),
          singleProcessContainers(process.burstTime.toString(), process.status),
          singleProcessContainers(process.arrivalTime.toString(), process.status),
          singleProcessContainers(process.memorySize.toString(), process.status),
          singleProcessContainers(process.status, process.status),

        ],
      ),
    );
  }

  Widget singleProcessContainers(String field, String status){
    bool isRunning = (status=="Running")?true:false;
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        color: (isRunning)?Color(0xffFCCD73):Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 2.0, // Adjust the border width as needed
        ),
      ),
      child: Center(
        child: DefaultTextStyle(
          child: Text(field),
          style:  TextStyle(color:(isRunning)?Colors.white: Colors.orange[400], fontSize: 20),
        ),
      ),
    );
  }
}