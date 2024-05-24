import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scheduling_os/scheduling/Homepage.dart';
import 'package:scheduling_os/scheduling/process.dart';

class PrioritySched extends StatefulWidget {
  const PrioritySched({super.key});

  @override
  State<PrioritySched> createState() => _PrioritySchedState();
}

class _PrioritySchedState extends State<PrioritySched> {
  List<Process> processes = [];
  int _counter = 0;
  late Timer _timer;
  int processNum =0;
  bool isGenerating = false;
  int TimerCounter =0;
  bool isPaused = true;
  int _freeMemory = 1000;
  MemoryManager memoryManager = MemoryManager(
    memoryBlocks: List.generate(100, (index) => MemoryBlock(startAddress: index * 10, size: 10)),
    pageSize: 10,
    totalMemory: 1000,
  );

  late int pageSize = 0;
  late int totalMemory = 0;

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
                    memoryBlocks: List.generate(totalMemory ~/ pageSize, (index) => MemoryBlock(startAddress: index * pageSize, size: pageSize)),
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

  void _startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!isPaused) {
        TimerCounter++;

        //change number if want slower
        if (TimerCounter % 2 == 0) {
          PriorityScheduling(processes, memoryManager);
          setState(() {
            _counter++;

            if (isGenerating) {
              generateRandomly();
            }
            _freeMemory = memoryManager.memoryBlocks.where((block) => block.isFree).length * memoryManager.pageSize;
          });
        }
      }
    });
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
      PriorityScheduling(processes, memoryManager);


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
                        Column(
                          children: [
                            Column(
                                children: [
                                  const SizedBox(height: 10,),
                                  DefaultTextStyle(style: TextStyle(
                                    fontFamily: 'Kavoon',
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ), child: Text('Priority Scheduling')),
                                  DefaultTextStyle(
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ), child:  Text(
                                      '0 is the highest priority... 2 is the lowest priority'))
                                ]
                            ),
                          ]
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
                                  'CPU Time: ${_counter.toString()} s'
                                      '   Free Memory: $_freeMemory KB',
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
                            Padding(padding: EdgeInsets.only(top: 50)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,


                              children: [
                                SizedBox(height: 20),
                                Padding(
                                  padding:EdgeInsets.only(left:20, right:40),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          tableTitle("Page Number"),
                                          tableTitle("Frame Number"),
                                          tableTitle("In Memory"),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        height: size.height * 0.5,
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
                                                            singleProcessContainers(entry['virtualPageNumber']!, 'N/A'),
                                                            singleProcessContainers(entry['physicalFrameNumber']!, 'N/A'),
                                                            singleProcessContainers(entry['inMemory']!, 'N/A'),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              );
                                            }
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                Padding(
                                  padding:EdgeInsets.only(left:40, right:20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          tableTitle("Process ID"),
                                          tableTitle("Burst Time"),
                                          tableTitle("Arrival Time"),
                                          tableTitle("Memory Size"),
                                          tableTitle("Priority"),
                                          tableTitle("Status"),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        height: size.height * 0.5,
                                        child: LayoutBuilder(
                                            builder: (context, constraints){
                                              double width = constraints.maxWidth;
                                              double height = constraints.maxHeight;
                                              //print('$width, $height');
                                              return  Container(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: processes.map((process)
                                                    {
                                                      return Padding(
                                                        padding: EdgeInsets.only(bottom:5),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            singleProcessContainers(process.processId, process.status),
                                                            singleProcessContainers(process.burstTime.toString(), process.status),
                                                            singleProcessContainers(process.arrivalTime.toString(), process.status),
                                                            singleProcessContainers(process.memorySize.toString(), process.status),
                                                            singleProcessContainers(process.priority.toString(), process.status),
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
                                      // Visual representation of the memory blocks in beehive layout
                                      SizedBox(height: 20),
                                      Container(
                                        height: 100,
                                        width: 500,
                                        child: Stack(
                                          children: memoryManager.memoryBlocks.map((block) {
                                            return Positioned(
                                              left: block.startAddress.toDouble(),
                                              child: Container(
                                                width: block.size.toDouble(),
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: block.isFree ? Colors.green : Colors.red,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2.0, // Adjust the border width as needed
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      // Show Processes in memory

                                    ],
                                  ),

                                ),

                              ],
                            ),
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
      padding: EdgeInsets.only(bottom:10, left:100, right:100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          singleProcessContainers(process.processId, process.status),
          singleProcessContainers(process.burstTime.toString(), process.status),
          singleProcessContainers(process.arrivalTime.toString(), process.status),
          singleProcessContainers(process.memorySize.toString(), process.status),
          singleProcessContainers(process.priority.toString(), process.status),
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

  void generateNewProcess() {
    // Generate random values for the new process
    Random random = Random();
    String processId = 'P${processNum+ 1}';
    int arrivalTime = _counter; // Random arrival time between 0 and 99
    int burstTime = random.nextInt(9)+1;
    //int burstTime = 4;
    int memorySize = random.nextInt(99)+1; // Random memory size between 0 and 99
    int priority = random.nextInt(3); // Random priority between 0 and 2
    String status = 'Job Queue'; // Initial status is 'Job Queue
    List<Pagee> pages = [];
    // Create a new Process object with the generated values
    Process newProcess = Process(processId, arrivalTime, memorySize, priority, burstTime: burstTime, status: status, pages: pages);

    if (memorySize < _freeMemory && memoryManager.jobQueue.isNotEmpty) {
      return;
    }

    memoryManager.allocateProcess(newProcess);

    setState(() {
      _freeMemory = memoryManager.memoryBlocks.where((block) => block.isFree).length * memoryManager.pageSize;
      processNum++;
      processes.add(newProcess);
    });
  }

  void generateRandomly(){
    Random random = Random();

    int randomTime = random.nextInt(2) + _counter;

    if(_counter==randomTime){
      generateNewProcess();
    }
  }
}


