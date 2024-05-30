import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
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
  int _freeMemory = 1000;

  late int pageSize = 0;
  late int totalMemory = 0;

  MemoryManager memoryManager = MemoryManager(
    memoryBlocks: List.generate(100, (index) => MemoryBlock(startAddress: index * 10, processId: '', size: 10)),
    pageSize: 10,
    totalMemory: 1000,
  );

  bool isReadyFiltered =true;
  bool isJobFiltered =true;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _showMemoryConfigurationDialog();
    });
  }

  void _showMemoryConfigurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Memory Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Page Size'),
                onChanged: (value) {
                  pageSize = int.parse(value);
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Total Memory'),
                onChanged: (value) {
                  totalMemory = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // If no value or invalid value is entered, show an alert message
                if (pageSize == 0 || totalMemory == 0 || totalMemory % pageSize != 0 || pageSize > totalMemory || pageSize < 0 || totalMemory < 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content: const Text('Please enter valid values for Page Size and Total Memory. Total Memory must be a multiple of Page Size.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                setState(() {
                  memoryManager = MemoryManager(
                    memoryBlocks: List.generate(totalMemory ~/ pageSize, (index) => MemoryBlock(startAddress: index * pageSize, processId: '', size: pageSize)),
                    pageSize: pageSize,
                    totalMemory: totalMemory,
                  );
                  _freeMemory = totalMemory;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


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
    int memorySize = random.nextInt(99)+1; // Random memory size between 0 and 99
    int priority = random.nextInt(3); // Random priority between 0 and 2
    String status = 'Job Queue';
    List<Pagee> pages = [];


    // if (memorySize < _freeMemory && memoryManager.jobQueue.isNotEmpty) {
    //   return;
    // }

    Process newProcess = Process(processId, arrivalTime, memorySize, priority, burstTime: burstTime, status: status, pages: pages);


    memoryManager.allocateProcess(newProcess);


    setState(() {
      _freeMemory = memoryManager.memoryBlocks.where((block) => block.isFree).length * memoryManager.pageSize;
      processNum++;
      processes.add(newProcess);
    });

  }


  void _startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!isPaused) {
      TimerCounter++;

      if (TimerCounter % 2 == 0){
        if (memoryManager.memoryBlocks.where((block) => block.isFree).isNotEmpty && memoryManager.partiallyAllocatedProcesses.isNotEmpty) {
          memoryManager.checkForFreeMemoryThenAllocateRemainingMemory();
        }
        memoryManager.checkForFreeMemoryThenAllocateFromJobQueue("FirstComeFirstServed");
        FirstComeFirstServed(processes, memoryManager);
        setState(() {
          _counter++;

          if(isGenerating){
            generateRandomly();
          }
          _freeMemory = memoryManager.memoryBlocks.where((block) => block.isFree).length * memoryManager.pageSize;

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

  List<Map<String, String>> generatePageTableData() {
    List<Map<String, String>> pageTableData = [];
    for (var entry in memoryManager.pageTable.entries) {
      pageTableData.add({
        'virtualPageNumber': entry.virtualPageNumber.toString(),
        'physicalFrameNumber': entry.physicalFrameNumber != null ? entry.physicalFrameNumber.toString() : 'N/A',
        'inMemory': entry.inMemory ? 'Yes' : 'No',
      });
    }
    return pageTableData;
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
    List<Map<String, String>> pageTableData = generatePageTableData();

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
                //back button
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
                      return Container(
                        width: width,
                        height: height,
                        child: Column(
                            children: [
                              //top part
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 80),

                                  Text(
                                    'CPU Time: ${_counter.toString()} s'
                                        '   Free Memory: $_freeMemory KB',
                                    style: TextStyle(color: Colors.white, fontSize: 30),
                                  ),
                                  Spacer(),
                                  //buttons
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

                              Container(
                                width: width,
                                height: height*0.85,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(height:25),

                                      Padding(padding:EdgeInsets.symmetric(horizontal: 60),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Padding(
                                              padding:EdgeInsets.only(left:20, right:40),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Visual representation of the memory blocks in beehive layout

                                                  Text(
                                                    'Memory Block',
                                                    style: TextStyle(
                                                      fontFamily: 'Kavoon',
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Container(
                                                    height: constraints.maxHeight*0.4,
                                                    width: constraints.maxWidth*0.27,
                                                    color: Colors.white.withOpacity(0.3),
                                                    padding: EdgeInsets.all(10), // Padding
                                                    child: SingleChildScrollView(
                                                      child: Container(
                                                        //Height of the container should correctly fit the number of memory blocks
                                                        height: memoryManager.memoryBlocks.map((block) => block.size).reduce((value, element) => value + element).toDouble() * 4,
                                                        child: Stack(
                                                          children: memoryManager.memoryBlocks.map((block) {
                                                            return Positioned(
                                                              top: block.startAddress.toDouble()*3,
                                                              child: Container(
                                                                  width: 380,
                                                                  height: block.size.toDouble() * 5,
                                                                  decoration: BoxDecoration(
                                                                    color: block.isFree ? Colors.green : Colors.red,
                                                                    border: Border.all(
                                                                      color: Colors.white,
                                                                      width: 2.0, // Border width
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    block.processId,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      color: block.isFree ? Colors.black : Colors.white, // Improved contrast
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 16, // Font size
                                                                    ),
                                                                  )
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(height: 20),
                                                  Text(
                                                    'Page Table',
                                                    style: TextStyle(
                                                      fontFamily: 'Kavoon',
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      pageTableTitle("Page Number"),
                                                      pageTableTitle("Frame Number"),
                                                      pageTableTitle("In Memory"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  //page
                                                  Container(
                                                    height: size.height * 0.4,
                                                    child: LayoutBuilder(
                                                        builder: (context, constraints){
                                                          double width = constraints.maxWidth;
                                                          double height = constraints.maxHeight;
                                                          //print('$width, $height');
                                                          return Container(
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                children: pageTableData.map((entry)
                                                                {
                                                                  return Padding(
                                                                    padding: EdgeInsets.only(bottom:10),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        singlePageContainers(entry['virtualPageNumber']!, 'N/A'),
                                                                        singlePageContainers(entry['physicalFrameNumber']!, 'N/A'),
                                                                        singlePageContainers(entry['inMemory']!, 'N/A'),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                    ),
                                                  ),


                                                ],
                                              ),
                                            ),


                                            SizedBox(height: 20),
                                            Padding(
                                              padding:EdgeInsets.only(left:30),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Ready Queue',
                                                    style: TextStyle(
                                                      fontFamily: 'Kavoon',
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),


                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    color: Colors.white.withOpacity(0.4),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            tableTitle("Process ID"),
                                                            tableTitle("Burst Time"),
                                                            tableTitle("Arrival Time"),
                                                            tableTitle("Memory Size"),
                                                            tableTitle("Status"),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        Container(
                                                          height: constraints.maxHeight*0.3,
                                                          child: LayoutBuilder(
                                                              builder: (context, constraints){
                                                                double width = constraints.maxWidth;
                                                                double height = constraints.maxHeight;
                                                                //print('$width, $height');
                                                                return  Container(
                                                                  child: SingleChildScrollView(
                                                                    child: Column(
                                                                      children: (isReadyFiltered
                                                                          ? processes.where((process) => process.status != 'Job Queue').toList()
                                                                          : processes).map((process) {
                                                                        return Padding(
                                                                          padding: EdgeInsets.only(bottom: 5),
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
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height:constraints.maxHeight*0.02),

                                                  Text(
                                                    'Job Queue',
                                                    style: TextStyle(
                                                      fontFamily: 'Kavoon',
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),

                                                  SizedBox(height: 5,),
                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    color: Colors.white.withOpacity(0.2),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            tableTitle("Process ID"),
                                                            tableTitle("Burst Time"),
                                                            tableTitle("Arrival Time"),
                                                            tableTitle("Memory Size"),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        Container(
                                                          height: constraints.maxHeight*0.3,
                                                          child: LayoutBuilder(
                                                              builder: (context, constraints){
                                                                double width = constraints.maxWidth;
                                                                double height = constraints.maxHeight;
                                                                //print('$width, $height');
                                                                return  Container(
                                                                  child: SingleChildScrollView(
                                                                    child: Column(
                                                                      children: (isJobFiltered
                                                                          ? processes.where((process) => process.status == 'Job Queue').toList()
                                                                          : processes).map((process) {
                                                                        return Padding(
                                                                          padding: EdgeInsets.only(bottom: 5),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              singleProcessContainers(process.processId, process.status),
                                                                              singleProcessContainers(process.burstTime.toString(), process.status),
                                                                              singleProcessContainers(process.arrivalTime.toString(), process.status),
                                                                              singleProcessContainers(process.memorySize.toString(), process.status),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),








                                                ],
                                              ),

                                            ),



                                          ],
                                        ),),
                                    ],
                                  ),
                                ),
                              )
                            ]),


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

  Widget pageTableTitle(String title){
    return Container(
      height: 50,
      width: 130,
      decoration: BoxDecoration(
        color: Colors.orange[400],
        border: Border.all(
          color: Colors.white,
          width: 2.0, // Adjust the border width as needed
        ),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontSize: 18),
          child: Text(title),
        ),
      ),
    );
  }

  Widget singlePageContainers(String field, String status){
    bool isRunning = (status=="Running")?true:false;
    return Container(
      height: 50,
      width: 130,
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
          style:  TextStyle(color:(isRunning)?Colors.white: Colors.orange[400], fontSize: 18),
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