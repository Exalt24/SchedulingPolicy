
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
  int unallocatedPages = 0;
  int allocatedUnallocatedPages = 0;
  int allocatedPages = 0;
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
  String processId;
  bool isFree;

  MemoryBlock({required this.startAddress, required this.size, required this.processId, this.isFree = true});
}

class PageTableEntry {
  final int virtualPageNumber;
  int? physicalFrameNumber; // Nullable to represent page not in memory
  bool inMemory;

  PageTableEntry(this.virtualPageNumber, {this.physicalFrameNumber, this.inMemory = false});
}

class PageTable {
  final List<PageTableEntry> entries;
  PageTable(int size)
      : entries = List.generate(size, (index) => PageTableEntry(index));
}


class MemoryManager with ChangeNotifier {
  final List<MemoryBlock> memoryBlocks;
  final List<Process> readyQueue = [];
  final List<Process> jobQueue = [];
  final List<Process> partiallyAllocatedProcesses = [];
  final int pageSize;
  final int totalMemory;
  late final PageTable pageTable;

  MemoryManager(
      {required this.memoryBlocks, required this.pageSize, required this.totalMemory}) {
    pageTable = PageTable(totalMemory ~/ pageSize);
  }

  void allocateProcess(Process process) {
    // Calculate the number of pages required

    allocateRemainingMemory(process);

    int requiredPages = (process.memorySize / pageSize).ceil();
    var freeFrames = memoryBlocks.where((block) => block.isFree).toList();

    if (freeFrames.isEmpty) {
      jobQueue.add(process);
      process.status = "Job Queue";
      notifyListeners();
      return;
    }

    // Allocate as many pages as possible initially
    for (int i = 0; i < requiredPages && freeFrames.isNotEmpty; i++) {
      int freeFrameIndex = Random().nextInt(freeFrames.length);
      MemoryBlock freeFrame = freeFrames[freeFrameIndex];
      freeFrames.removeAt(freeFrameIndex);
      process.pages.add(Pagee(pageNumber: freeFrame.startAddress ~/ pageSize));
      freeFrame.isFree = false;
      freeFrame.processId = process.processId;
      var entry = pageTable.entries[freeFrame.startAddress ~/ pageSize];
      entry.physicalFrameNumber = freeFrame.startAddress ~/ pageSize;
      entry.inMemory = true;
      process.pages[i].inMemory = true;
      print("Page ${freeFrame.startAddress ~/ pageSize} loaded into frame ${freeFrame.startAddress ~/ pageSize}");
    }

    // Check first if all pages are allocated
    if (process.pages.length < requiredPages) {
      int remainingPages = requiredPages - process.pages.length;
      process.allocatedPages = process.pages.length;
      process.unallocatedPages = remainingPages;
      process.status = "Ready";
      partiallyAllocatedProcesses.add(process);
      notifyListeners();
      return;
    }

    // Add process to the ready queue
    readyQueue.add(process);
    process.status = "Ready";
    notifyListeners();
  }

  void allocateRemainingMemory (Process process) {

    if (process.unallocatedPages == 0) return;

    var freeFrames = memoryBlocks.where((block) => block.isFree).toList();
    for (int i = process.allocatedPages; i < process.allocatedPages + process.unallocatedPages; i++) {
      int freeFrameIndex = Random().nextInt(freeFrames.length);
      MemoryBlock freeFrame = freeFrames[freeFrameIndex];
      freeFrames.removeAt(freeFrameIndex);
      process.pages.add(Pagee(pageNumber: freeFrame.startAddress ~/ pageSize));
      freeFrame.isFree = false;
      freeFrame.processId = process.processId;
      var entry = pageTable.entries[freeFrame.startAddress ~/ pageSize];
      entry.physicalFrameNumber = freeFrame.startAddress ~/ pageSize;
      entry.inMemory = true;
      process.pages[i].inMemory = true;
      process.allocatedUnallocatedPages++;
      print("Unallocated Page ${freeFrame.startAddress ~/ pageSize} loaded into frame ${freeFrame.startAddress ~/ pageSize}");
    }

    if (process.allocatedUnallocatedPages == process.unallocatedPages) {
      process.unallocatedPages = 0;
      readyQueue.add(process);
      process.status = "Ready";
      partiallyAllocatedProcesses.remove(process);
      notifyListeners();
    }
  }



  void deallocateProcess(Process process, String policy) {
    print("Deallocating process ${process.processId}");
    for (var page in process.pages) {
      if (page.inMemory) {
        var entry = pageTable.entries[page.pageNumber];
        memoryBlocks[entry.physicalFrameNumber!].isFree = true;
        entry.physicalFrameNumber = null;
        entry.inMemory = false;
        page.inMemory = false;
      }
    }
    process.pages.clear();
    readyQueue.remove(process);
    allocateFromJobQueue(policy);

    notifyListeners();
  }

  void checkForFreeMemoryThenAllocateRemainingMemory() {
    Process process = partiallyAllocatedProcesses.first;
    var freeFrames = memoryBlocks.where((block) => block.isFree).toList();
    if (freeFrames.isNotEmpty) {
      allocateRemainingMemory(process);
    }
  }

  void allocateFromJobQueue(String policy) {
    if (jobQueue.isEmpty && partiallyAllocatedProcesses.isEmpty) return;

    Process processToAllocate;

    if (policy == 'FirstComeFirstServed') {
      if (partiallyAllocatedProcesses.isNotEmpty) {
        processToAllocate = partiallyAllocatedProcesses.removeAt(0);
        allocateRemainingMemory(processToAllocate);
      } else  {
        processToAllocate = jobQueue.removeAt(0);
        allocateProcess(processToAllocate);
      }
    } else if (policy == 'ShortestJobFirst') {
      if (partiallyAllocatedProcesses.isNotEmpty) {
        processToAllocate = partiallyAllocatedProcesses.removeAt(0);
        allocateRemainingMemory(processToAllocate);
      } else {
        jobQueue.sort((a, b) => a.burstTime.compareTo(b.burstTime));
        processToAllocate = jobQueue.removeAt(0);
        allocateProcess(processToAllocate);
      }

    } else if (policy == 'PriorityScheduling') {
      if (partiallyAllocatedProcesses.isNotEmpty) {
        processToAllocate = partiallyAllocatedProcesses.removeAt(0);
        allocateRemainingMemory(processToAllocate);

      } else {
        jobQueue.sort((a, b) => a.priority.compareTo(b.priority));
        processToAllocate = jobQueue.removeAt(0);
        allocateProcess(processToAllocate);
      }

    } else if (policy == 'RoundRobin') {
      if (partiallyAllocatedProcesses.isNotEmpty) {
        processToAllocate = partiallyAllocatedProcesses.removeAt(0);
        allocateRemainingMemory(processToAllocate);

      } else {
        processToAllocate = jobQueue.removeAt(0);
        allocateProcess(processToAllocate);
      }
    }

    notifyListeners();
  }

  void handlePageFault(Process process, int pageNumber) {
    var entry = pageTable.entries[pageNumber];
    if (!entry.inMemory) {
      var freeFrames = memoryBlocks.where((block) => block.isFree).toList();
      if (freeFrames.isNotEmpty) {
        int freeFrameIndex = selectFreeFrame(freeFrames);
        MemoryBlock freeFrame = freeFrames[freeFrameIndex];
        freeFrames.removeAt(freeFrameIndex);
        freeFrame.isFree = false;
        entry.physicalFrameNumber = freeFrame.startAddress ~/ pageSize;
        entry.inMemory = true;
        process.pages[pageNumber].inMemory = true;
        print("Page fault resolved: Process ${process.processId}, Page $pageNumber loaded into frame ${freeFrame.startAddress ~/ pageSize}");
      } else {
        // Handle no free frames available (e.g., page replacement or job queueing)
        jobQueue.add(process);
        process.status = "Job Queue";
        notifyListeners();
      }
    }
  }

  int selectFreeFrame(List<MemoryBlock> freeFrames) {
    return Random().nextInt(freeFrames.length);
  }
}





MemoryManager initializeMemory(int totalMemory, int pageSize, int workingSetSize) {
  List<MemoryBlock> memoryBlocks = [];
  int numBlocks = totalMemory ~/ pageSize;
  for (int i = 0; i < numBlocks; i++) {
    memoryBlocks.add(MemoryBlock(startAddress: i * pageSize, processId: '', size: pageSize));
  }
  return MemoryManager(memoryBlocks: memoryBlocks, pageSize: pageSize, totalMemory: totalMemory);
}



void FirstComeFirstServed(List<Process> processes, MemoryManager memoryManager) {
  if (processes.isNotEmpty) {
    // Get the first process in the list
    Process currentProcess = processes.first;

    // Allocate memory for the current process if it's not already allocated
    if (currentProcess.status == 'Ready') {
      for (var page in currentProcess.pages) {
        if (!page.inMemory) {
          print("Page ${page.pageNumber} not in memory");
          memoryManager.handlePageFault(currentProcess, page.pageNumber);
        }
      }
      currentProcess.status = 'Running';
    }

    // Decrement the burst time of the first process
    currentProcess.burstTime--;

    // If the burst time of the current process becomes 0, remove it from the list
    if (currentProcess.burstTime <= 0) {
      memoryManager.deallocateProcess(currentProcess, 'FirstComeFirstServed');

      processes.removeAt(0);
      // If there are more processes in the list, update the status of the next process to 'Running'
      if (processes.isNotEmpty) {
        processes.first.status = 'Running';
      }
    }
  }

}





void ShortestJobFirst(List<Process> processes, MemoryManager memoryManager) {
  if (processes.isNotEmpty) {
    int shortestIndex = 0;

    // Find the index of the process with the shortest burst time
    for (int i = 1; i < processes.length; i++) {
      if (processes[i].burstTime < processes[shortestIndex].burstTime) {
        if (processes[i].status != 'Job Queue') {
        shortestIndex = i;
        }
      }
    }

    if (processes[shortestIndex].status == 'Ready') {
      for (var page in processes[shortestIndex].pages) {
        if (!page.inMemory) {
          memoryManager.handlePageFault(processes[shortestIndex], page.pageNumber);
        }
      }
      processes[shortestIndex].status = 'Running';
    }

    // Decrement the burst time
    processes[shortestIndex].burstTime--;

    processes[shortestIndex].status = 'Running';

    for (int i = 0; i < processes.length; i++) {
      if (i != shortestIndex) {
        if (processes[i].status != 'Job Queue') {
          processes[i].status = 'Ready';
        }
      }
    }

    // If the burst time of the shortest job becomes 0, remove it from the list
    if (processes[shortestIndex].burstTime <= 0) {
      memoryManager.deallocateProcess(processes[shortestIndex], 'ShortestJobFirst');
      processes.removeAt(shortestIndex);
    }
  }
}

void PriorityScheduling(List<Process> processes, MemoryManager memoryManager) {
  if (processes.isNotEmpty) {
    int priorityIndex = 0;

    // Find the index of the process with the shortest burst time
    for (int i = 1; i < processes.length; i++) {
      if (processes[i].priority < processes[priorityIndex].priority) {
        if (processes[i].status != 'Job Queue') {
          priorityIndex = i;
        }
      }
    }

    if (processes[priorityIndex].status == 'Ready') {
      for (var page in processes[priorityIndex].pages) {
        if (!page.inMemory) {
          memoryManager.handlePageFault(processes[priorityIndex], page.pageNumber);
        }
      }
      processes[priorityIndex].status = 'Running';
    }

    // Decrement the burst time
    processes[priorityIndex].burstTime--;


    // Update its status to "Running"
    processes[priorityIndex].status = 'Running';

    // Update the status of other processes to "Waiting"
    for (int i = 0; i < processes.length; i++) {
      if (i != priorityIndex) {
        if (processes[i].status != 'Job Queue') {
          processes[i].status = 'Ready';
        }
      }
    }

    // If the burst time of the shortest job becomes 0, remove it from the list
    if (processes[priorityIndex].burstTime <= 0) {
      memoryManager.deallocateProcess(processes[priorityIndex], 'PriorityScheduling');
      processes.removeAt(priorityIndex);
    }

  }
}





