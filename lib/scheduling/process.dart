
import 'dart:math';

import 'package:flutter/cupertino.dart';

class Process {
  final String processId;
  final int arrivalTime;
  int burstTime;
  final int memorySize;
  final int priority;
  String status;
  List<Pagee> pages;

  Process(this.processId, this.arrivalTime, this.memorySize, this.priority, {required this.burstTime, required this.status, required this.pages});
}

class Pagee {
  final int pageNumber;
  bool inMemory;

  Pagee({required this.pageNumber, this.inMemory = false});
}

class MemoryBlock {
  final int startAddress;
  final int size;
  bool isFree;

  MemoryBlock({required this.startAddress, required this.size, this.isFree = true});
}

class MemoryManager with ChangeNotifier {
  final List<MemoryBlock> memoryBlocks;
  final List<Process> readyQueue = [];
  final List<Process> jobQueue = [];
  final int pageSize;
  final int totalMemory;
  final int workingSetSize;

  MemoryManager({required this.memoryBlocks, required this.pageSize, required this.totalMemory, required this.workingSetSize});

  void allocateProcess(Process process) {
    int requiredPages = (process.memorySize / pageSize).ceil();
    List<MemoryBlock> freeBlocks = memoryBlocks.where((block) => block.isFree).toList();

    if (freeBlocks.length >= requiredPages) {
      for (int i = 0; i < requiredPages; i++) {
        freeBlocks[i].isFree = false;
        process.pages.add(Pagee(pageNumber: freeBlocks[i].startAddress ~/ pageSize, inMemory: true));
      }
      readyQueue.add(process);
      process.status = "Ready";
    } else {
      jobQueue.add(process);
      process.status = "Job Queue";
    }
    notifyListeners();
  }

  void deallocateProcess(Process process) {
    for (var page in process.pages) {
      var block = memoryBlocks.firstWhere((block) => block.startAddress == page.pageNumber * pageSize);
      block.isFree = true;
    }
    process.pages.clear();
    readyQueue.remove(process);
    allocateFromJobQueue();
    notifyListeners();
  }

  void allocateFromJobQueue() {
    if (jobQueue.isNotEmpty) {
      var process = jobQueue.removeAt(0);
      allocateProcess(process);
    }
  }

  void handlePageFault(Process process, int pageNumber) {
    var pagesInMemory = process.pages.where((page) => page.inMemory).toList();
    if (pagesInMemory.length >= workingSetSize) {
      pagesInMemory.first.inMemory = false;
    }
    var pageToLoad = process.pages.firstWhere((page) => page.pageNumber == pageNumber);
    pageToLoad.inMemory = true;
    notifyListeners();
  }
}

MemoryManager initializeMemory(int totalMemory, int pageSize, int workingSetSize) {
  List<MemoryBlock> memoryBlocks = [];
  for (int i = 0; i < totalMemory; i += pageSize) {
    memoryBlocks.add(MemoryBlock(startAddress: i, size: pageSize));
  }
  return MemoryManager(memoryBlocks: memoryBlocks, pageSize: pageSize, totalMemory: totalMemory, workingSetSize: workingSetSize);
}

void FirstComeFirstServed(List<Process> processes, MemoryManager memoryManager) {
  if (processes.isNotEmpty) {
    // Get the first process in the list
    Process currentProcess = processes.first;

    // Decrement the burst time of the first process
    currentProcess.burstTime--;

    // Allocate memory for the current process if it's not already allocated
    if (currentProcess.status == 'Ready') {
      memoryManager.handlePageFault(currentProcess, currentProcess.pages.first.pageNumber);
      currentProcess.status = 'Running';
    }

    // If the burst time of the current process becomes 0, remove it from the list
    if (currentProcess.burstTime <= 0) {
      processes.removeAt(0);
      memoryManager.deallocateProcess(currentProcess);

      // If there are more processes in the list, update the status of the next process to 'Running'
      if (processes.isNotEmpty) {
        processes.first.status = 'Running';
      }
    }
  }
}



void ShortestJobFirst(List<Process> processes){
  if (processes.isNotEmpty) {
    int shortestIndex = 0;

    // Find the index of the process with the shortest burst time
    for (int i = 1; i < processes.length; i++) {
      if (processes[i].burstTime < processes[shortestIndex].burstTime) {
        shortestIndex = i;
      }
    }

    // Decrement the burst time
    processes[shortestIndex].burstTime--;

    // Update its status to "Running"
    processes[shortestIndex].status = 'Running';

    // Update the status of other processes to "Waiting"
    for (int i = 0; i < processes.length; i++) {
      if (i != shortestIndex) {
        processes[i].status = 'Waiting';
      }
    }

    // If the burst time of the shortest job becomes 0, remove it from the list
    if (processes[shortestIndex].burstTime == 0) {
      processes.removeAt(shortestIndex);

    }

  }
}

void PriorityScheduling(List<Process> processes){
  if (processes.isNotEmpty) {
    int priorityIndex = 0;

    // Find the index of the process with the shortest burst time
    for (int i = 1; i < processes.length; i++) {
      if (processes[i].priority < processes[priorityIndex].priority) {
        priorityIndex = i;
      }
    }

    // Decrement the burst time
    processes[priorityIndex].burstTime--;


    // Update its status to "Running"
    processes[priorityIndex].status = 'Running';

    // Update the status of other processes to "Waiting"
    for (int i = 0; i < processes.length; i++) {
      if (i != priorityIndex) {
        processes[i].status = 'Waiting';
      }
    }

    // If the burst time of the shortest job becomes 0, remove it from the list
    if (processes[priorityIndex].burstTime == 0) {
      processes.removeAt(priorityIndex);
    }

  }
}

//void RoundRobinAlgorithm(int quantumTime) {
//     // Check if the current time is within the quantum time
//     if (time <= quantumTime) {
//       time++;
//       // Check if there are processes to execute
//       if (processes.isNotEmpty) {
//         // Get the current process
//         Process currentProcess = processes[currentIndex];
//         // Check if the current process has burst time left
//         if (currentProcess.burstTime > 0) {
//           // Decrement the burst time of the current process
//           currentProcess.burstTime--;
//
//
//           if(currentProcess.burstTime==0){
//             if(currentIndex==processes.length-1){
//               processes.removeAt(currentIndex);
//               currentIndex=0;
//             }else{
//               processes.removeAt(currentIndex);
//               time = 0;
//
//             }
//           }
//
//           currentProcess.status = "Running";
//         }
//         else {
//           // Reset the time if the current process finishes
//           time = 0;
//
//           //last element
//           if(currentIndex==processes.length-1){
//             processes.removeAt(currentIndex);
//             currentIndex =0;
//           }else{
//             processes.removeAt(currentIndex);
//           }
//
//         }
//       }
//     }
//     else {
//       // Reset the time if it exceeds the quantum time
//       time = 0;
//       if (processes.isNotEmpty) {
//         if(processes[currentIndex].burstTime==0){
//           if(currentIndex==processes.length-1){
//             processes.removeAt(currentIndex);
//             currentIndex =0;
//           }else{
//             processes.removeAt(currentIndex);
//           }
//         }
//
//       }
//       processes[currentIndex].status = "Waiting";
//       currentIndex = (currentIndex + 1) % processes.length;
//     }
//   }



